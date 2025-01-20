{ lib, ... }:
let
  inherit (lib)
    types
    escape
    concatStringsSep
    mapAttrsToList
    ;
in
rec {
  mkEnabledOption =
    description:
    lib.mkOption {
      inherit description;
      type = types.bool;
      default = true;
    };

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  # For hyprland
  createUWSMCommand = command: "uwsm app -- ${command}";

  recursiveMergeAttrs =
    attrLists:
    let
      inherit (lib)
        zipAttrsWith
        tail
        head
        all
        isList
        unique
        concatLists
        isAttrs
        last
        ;

      f =
        attrPath:
        zipAttrsWith (
          n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values
        );
    in
    f [ ] attrLists;

  escapeIfNecessary =
    let
      needsEscaping = str: null != builtins.match "[a-zA-Z0-9]+" str;
    in
    str: if needsEscaping str then str else ''"${escape [ "\$" "\"" "\\" "\`" ] str}"'';

  attrsToLines =
    attrs:
    concatStringsSep "\n" (mapAttrsToList (n: v: ''${n}=${escapeIfNecessary (toString v)}'') attrs)
    + "\n";
}
