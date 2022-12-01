#[cfg_attr(target_os = "android", ndk_glue::main(backtrace = "on"))]
pub fn main() {
    let activity = ndk_glue::native_activity();
    let mut packages = activity
        .asset_manager()
        .open(&std::ffi::CString::new("packages").unwrap())
        .unwrap();
    let packages = std::str::from_utf8(packages.get_buffer().unwrap()).unwrap();
    #[allow(unused_must_use)]
    for package in packages.lines() {
        std::process::Command::new("su")
            .args(["--command", "pm", "uninstall", package])
            .status();
    }
    activity.finish();
}
