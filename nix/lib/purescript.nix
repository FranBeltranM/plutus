{ stdenv
, nodejs
, easyPS
, nix-gitignore
, buildNodeModules
}:

{
  # path to generated purescript sources
  psSrc
  # path to project sources
, src
  # name of the project
, name
  # additional dependencies required to build node_modules (e.g available during `npm install`)
, additionalNpmBuildInputs ? [ ]
  # packages as generated by psc-pacakge2nix
, packages
  # spago packages as generated by spago2nix
, spagoPackages
  # web-common project
, webCommon
  # test script
, checkPhase ? ""
}:
let
  # Cleans the source based on the patterns in ./.gitignore and the additionalIgnores
  cleanSrcs = nix-gitignore.gitignoreSource [ "/*.adoc" "/*.nix" ] src;

  # A store path containing [ node_modules/ package.json  package-lock.json ]
  nodeModules = buildNodeModules { projectDir = src; buildInputs = additionalNpmBuildInputs; };
in
stdenv.mkDerivation {
  inherit name;
  src = cleanSrcs;
  buildInputs = [ nodeModules easyPS.purs easyPS.spago easyPS.psc-package ];
  buildPhase = ''
    export HOME=$NIX_BUILD_TOP
    shopt -s globstar
    ln -s ${nodeModules}/node_modules node_modules
    ln -s ${psSrc} generated
    ln -s ${webCommon} ../web-common

    sh ${spagoPackages.installSpagoStyle}
    sh ${spagoPackages.buildSpagoStyle}
    ${nodejs}/bin/npm run webpack
  '';
  installPhase = ''
    mv dist $out
  '';
  doCheck = true;
}