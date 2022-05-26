pkgs: self: super:
{
  floating-print = with pkgs;
    writers.writeBashBin "floating-print" ''
      temp=`mktemp --suffix=.png`

      ${maim}/bin/maim -s $temp

      dimensions=`${imagemagick}/bin/identify -ping -format '%wx%h' $temp`

      ${sxiv}/bin/sxiv $temp -b -g $dimensions -T

      rm $temp
    '';
}
