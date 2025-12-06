let
  future-gadget-lab = import ../hosts/future-gadget-lab;
  future-gadget-lab-keys = with future-gadget-lab; [
    sshLoginKey
    sshSystemKey
  ];

  tennouji-nae = import ../hosts/tennouji-nae;
  tennouji-nae-keys = with tennouji-nae; [
    sshLoginKey
    sshSystemKey
  ];
in
{
  "caddy.age".publicKeys = future-gadget-lab-keys;

  "bar-assistant.age".publicKeys = tennouji-nae-keys;
  "anki-sync-nickthegroot.age".publicKeys = tennouji-nae-keys;
  "linkwarden.age".publicKeys = tennouji-nae-keys;
}
