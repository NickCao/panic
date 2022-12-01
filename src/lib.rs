#[cfg_attr(target_os = "android", ndk_glue::main(backtrace = "on"))]
pub fn main() {
    const PACKAGES: [&'static str; 1] = ["rust.panic"];
    #[allow(unused_must_use)]
    for package in PACKAGES {
        std::process::Command::new("su")
            .args(["--command", "pm", "uninstall", package])
            .status();
    }
    ndk_glue::native_activity().finish();
}
