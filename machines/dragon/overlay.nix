{ inputs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # Use the standard nix package to avoid rebuilds due to cudaSupport!
      nix = inputs.nixpkgs.legacyPackages.aarch64-linux.nix;

      onnxruntime = prev.onnxruntime.override { ncclSupport = false; };
      python3-cuda = prev.python3.override {
        packageOverrides = python-final: python-prev: {
          # The python package does not respect ncclSupport!
          onnxruntime = python-prev.onnxruntime.overrideAttrs {
            buildInputs = [
              prev.oneDNN
              prev.re2
              final.onnxruntime.protobuf
              final.onnxruntime
            ]
            ++ lib.optionals final.onnxruntime.passthru.cudaSupport (
              with final.onnxruntime.passthru.cudaPackages;
              [
                libcublas # libcublasLt.so.XX libcublas.so.XX
                libcurand # libcurand.so.XX
                libcufft # libcufft.so.XX
                cudnn # libcudnn.soXX
                cuda_cudart # libcudart.so.XX
              ]
            );
          };
        };
      };
    })
  ];
}
