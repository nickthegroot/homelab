let
  getKeys =
    # Little hacky, but easier then trying to actually get mylib
    file: with (import file { mylib = null; }); [
      sshLoginKey
      sshSystemKey
    ];

  hashida-itaru-keys = getKeys ../hosts/hashida-itaru;
in
{
  "anki-sync-nickthegroot.age".publicKeys = hashida-itaru-keys;
}
