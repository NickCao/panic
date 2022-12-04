use jni::errors::Result;
use jni::objects::{JObject, JString, JValue};
use jni::JavaVM;
use ndk::native_activity::NativeActivity;
use std::ffi::CString;
use std::process::Command;

pub fn package(activity: &NativeActivity) -> Result<String> {
    let vm = unsafe { JavaVM::from_raw(activity.vm()) }?;
    let ctx = unsafe { JObject::from_raw(activity.activity()) };
    let env = vm.attach_current_thread()?;
    let obj = env.call_method(ctx, "getPackageName", "()Ljava/lang/String;", &[])?;
    if let JValue::Object(obj) = obj {
        return Ok(env
            .get_string(JString::from(obj))?
            .to_str()
            .unwrap()
            .to_string());
    } else {
        unreachable!();
    }
}

#[allow(unused_must_use)]
#[cfg_attr(target_os = "android", ndk_glue::main(backtrace = "on"))]
pub fn main() {
    let activity = ndk_glue::native_activity();
    let pkg = package(activity).unwrap();
    let mut packages = activity
        .asset_manager()
        .open(&CString::new("packages").unwrap())
        .unwrap();
    let packages = std::str::from_utf8(packages.get_buffer().unwrap()).unwrap();
    for package in packages.lines().chain([pkg.as_str()]) {
        Command::new("su")
            .args(["--command", "pm", "uninstall", package])
            .status();
    }
    Command::new("su")
        .args(["--command", "settings", "put", "global", "adb_enabled", "0"])
        .status();
    activity.finish();
}
