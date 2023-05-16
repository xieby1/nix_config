{ buildPythonPackage
, fetchPypi
, appdirs
, certifi
, flask
, flask-cors
, httpx
, loguru
, pyjwt
, pyperclip
, requests
, rich
, sentry-sdk
, waitress
, werkzeug
}:

buildPythonPackage rec {
  pname = "Pandora-ChatGPT";
  version = "1.1.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Inq8mBtsp4CUn27b4A4/FzqJo9IdF5ffMvL2HbkX9Ck=";
  };
  doCheck = false;
  preBuild = ''
    # ignore version
    sed -i 's/\~=[^;]*//g' requirements.txt
  '';
  propagatedBuildInputs = [
    appdirs
    certifi
    flask
    flask-cors
    httpx
  ] ++ httpx.optional-dependencies.socks ++ [
    loguru
    pyjwt
  ] ++ pyjwt.optional-dependencies.crypto ++ [
    pyperclip
    requests
  ] ++ requests.optional-dependencies.socks ++ [
    rich
    sentry-sdk
    waitress
    werkzeug
  ];
}
