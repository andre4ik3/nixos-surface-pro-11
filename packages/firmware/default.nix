{ stdenv, rsync, path }:

stdenv.mkDerivation {
  name = "denali-firmware";
  src = path;

  nativeBuildInputs = [ rsync ];

  buildCommand = ''
    mkdir -p $out/lib/firmware
    find . -exec touch --date=2000-01-01 {} +

    # These cause USB to disconnect during boot... for some reason (breaking the installer)
    # See https://github.com/dwhinham/linux-surface-pro-11?tab=readme-ov-file#firmware-blobs
    rsync -av \
      --exclude='qcom/x1e80100/microsoft/Denali/adsp_dtb.mbn' \
      --exclude='qcom/x1e80100/microsoft/Denali/qcadsp8380.mbn' \
      ./ "$out"/lib/firmware
    #rsync -av ./ "$out"/lib/firmware
  '';
}
