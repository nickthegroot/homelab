let
  tennouji-nae = import ../hosts/tennouji-nae;
  tennouji-nae-keys = with tennouji-nae; [
    sshLoginKey
    sshSystemKey
  ];

in
{
  "maybe-finance.age".publicKeys = tennouji-nae-keys;
}
