{ pkgs
, lib
, makeWrapper
, nodejs ? pkgs.nodejs_18
}:

let
  fetchElmDeps = pkgs.callPackage ./lib/fetchElmDeps.nix { };

  # Haskell packages that require ghc 9.8
  # > "Thank you captain obvious"
  hs98Pkgs = pkgs.haskell.packages.ghc98.override {
    overrides =
      self: super:
      {
        elm = pkgs.haskell.lib.compose.overrideCabal (drv: {
          # sadly with parallelism most of the time breaks compilation
          enableParallelBuilding = false;
          preConfigure = fetchElmDeps {
            elmPackages = (import packages/elm/elm-srcs.nix);
            elmVersion = drv.version;
            registryDat = packages/elm/registry.dat;
          };
          buildTools = drv.buildTools or [ ] ++ [ makeWrapper ];
          postInstall = ''
            wrapProgram $out/bin/elm \
              --prefix PATH ':' ${lib.makeBinPath [ nodejs ]}
          '';

          description = "Delightful language for reliable webapps";
          homepage = "https://elm-lang.org/";
          license = lib.licenses.bsd3;
          maintainers = with lib.maintainers; [
            domenkozar
            turbomack
          ];
        }) (self.callPackage ./packages/elm { });

        inherit fetchElmDeps;

        ansi-wl-pprint = pkgs.haskell.lib.compose.overrideCabal (drv: {
          jailbreak = true;
        }) (self.callPackage ./packages/elm/ansi-wl-pprint { });
      };
  };

  # Haskell packages that require ghc 8.10
  hs810Pkgs = import ./packages/ghc8_10 { inherit pkgs lib; };

  # Haskell packages that require ghc 9.2
  hs92Pkgs = import ./packages/ghc9_2 { inherit pkgs lib; };

  # Patched, originally npm-downloaded, packages
  patchedNodePkgs = import ./packages/node { inherit pkgs lib nodejs makeWrapper; };

  assembleScope = self: basics:
    {
      inherit (hs98Pkgs) elm;
    }
    // (hs92Pkgs self).elmPkgs // (hs810Pkgs self).elmPkgs // (patchedNodePkgs self) // basics;
in
lib.makeScope pkgs.newScope
  (self: assembleScope self
    (with self; {
      inherit fetchElmDeps nodejs;

      /* Node/NPM based dependencies can be upgraded using script `packages/generate-node-packages.sh`.

        * Packages which rely on `bin-wrap` will fail by default
          and can be patched using `patchBinwrap` function defined in `packages/lib.nix`.

        * Packages which depend on npm installation of elm can be patched using
          `patchNpmElm` function also defined in `packages/lib.nix`.
      */
      elmLib =
        let
          hsElmPkgs = hs810Pkgs // self;
        in
        import ./lib {
          inherit lib;
          inherit (pkgs) writeScriptBin stdenv;
          inherit (self) elm;
        };

      elm-json = callPackage ./packages/elm-json { };

      elm-test-rs = callPackage ./packages/elm-test-rs { };

      elm-test = callPackage ./packages/elm-test { };

      lamdera = callPackage ./packages/lamdera { };
    })
  )
