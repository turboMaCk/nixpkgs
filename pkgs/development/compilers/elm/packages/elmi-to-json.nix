{ mkDerivation, aeson, async, base, binary, bytestring, containers
, directory, filepath, hpack, optparse-applicative, safe-exceptions
, stdenv, text, fetchgit
}:
mkDerivation {
  pname = "elmi-to-json";
  version = "0.19.4";
  src = fetchgit {
    url = "https://github.com/stoeffel/elmi-to-json.git";
    rev = "61fbc861fe7d63ce22d6e0350dce3f1bf41c79f3";
    sha256 = "1hcggk4p3slhmfhzi6ah1h1jap34kiidbbf92jr4b7i0rwv1s18r";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson async base binary bytestring containers directory filepath
    optparse-applicative safe-exceptions text
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [ base ];
  prePatch = "hpack";
  homepage = "https://github.com/stoeffel/elmi-to-json#readme";
  description = "Translates elmi binary files to JSON representation";
  license = stdenv.lib.licenses.bsd3;
  maintainers = with stdenv.lib.maintainers; [ turbomack ];
}
