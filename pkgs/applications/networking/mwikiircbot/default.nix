{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "mwikiircbot-${version}";
  version = "2015-01-07";

  src = fetchFromGitHub {
    owner = "fenhl";
    repo = "mwikiircbot";
    rev = "889df164d330387f23f6b5f1c2861b50080beec9";
    sha256 = "0qzb735b7h81374yifm5gxhp81mcjsqdf79hjchzhhcbwragwpnx";
  };

  disabled = !python3Packages.isPy3k;

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r mwikiircbot.py $out/bin/

    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  pythonPath = [ python3Packages.docopt python3Packages.ircbotframework ];

  meta = with stdenv.lib; {
    description = "IRC bot that sits in one or more IRC channels and posts a livestream of recent changes from a MediaWiki to the channels";
    homepage = https://github.com/fenhl/mwikiircbot/;
    maintainers = with maintainers; [ fadenb ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
