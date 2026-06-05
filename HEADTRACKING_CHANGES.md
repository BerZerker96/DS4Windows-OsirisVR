# VR Head-Tracking (UDP) addition — changed files

## How it works
The UDP head signal is injected as the controller's OWN gyro, at the source: inside
the device's motion parsing (handleSixaxis / handleDS3Sixaxis / the Switch/JoyCon
motion block), right after the physical gyro is read and BEFORE the motion event
(SixAccelMoved / FireSixAxisEvent) fires. That ordering matters: that event is what
drives gyro->mouse and gyro->stick output, so the override must land before it.
Because every consumer (mapping, gyro mouse/stick, the DSU motion UDP server, the
readings graph, calibration) derives from the same cState.Motion, they all see the
headset as native controller gyro. Stale data -> zeroed, so the real gyro never leaks.

## Device coverage (all input families)
Injection added to every motion path so it works regardless of controller:
- DS4 / DualShock 4      -> DS4Sixaxis.handleSixaxis (slot param added)
- DualSense / DS Edge    -> same handleSixaxis path  (THIS is the user's controller)
- DualShock 3            -> DS4Sixaxis.handleDS3Sixaxis
- Switch Pro             -> SwitchProDevice motion block (before FireSixAxisEvent)
- JoyCon                 -> JoyConDevice motion block (before FireSixAxisEvent)

## New files
- DS4Control/HeadTrackingUdpListener.cs — UDP listener; parses OpenTrack 48-byte
  format (6 LE doubles: x,y,z,yaw,pitch,roll) from 6DOFtoUDP.py; derives deg/s.
- DS4Control/HeadTrackingSettings.cs — per-controller options + HeadTrackingMode enum.
- DS4Control/HeadTrackingManager.cs — owns per-slot listeners; ApplyGyroToMotion(),
  Reconcile() (socket lifecycle), StopAll().
- DS4Forms/HeadTrackingControl.xaml(.cs) — the GUI panel.

## Edited files
- DS4Library/DS4Sixaxis.cs — handleSixaxis gained an `int device` param; both
  handleSixaxis and handleDS3Sixaxis call ApplyGyroToMotion before the event.
- DS4Library/DS4Device.cs, InputDevices/DualSenseDevice.cs — pass the slot to handleSixaxis.
- DS4Library/InputDevices/DS3Device.cs — (unchanged call; override now inside handle).
- DS4Library/InputDevices/SwitchProDevice.cs, JoyConDevice.cs — override before FireSixAxisEvent.
- DS4Control/ScpUtil.cs — Global.headTracking[] (one per slot).
- DS4Forms/ViewModels/ControllerListViewModel.cs — CompositeDeviceModel.HeadTracking.
- DS4Control/ControlService.cs — ApplyHeadTracking() reconciles the socket + stick modes;
  called in On_Report; StopAll() in Stop().
- DS4Forms/MainWindow.xaml — panel docked under the controller list.

## IMPORTANT to actually see an effect
HijackGyro only changes what the gyro produces — you still need the profile's gyro
OUTPUT set to something. In the profile editor set Gyro to "Mouse" (for aim) or
"Joystick/Stick" so the (now head-driven) gyro maps to an output. If gyro output is
"None", hijacking it does nothing visible.

## Notes
- Settings are in-memory per session (not yet persisted to profile/config XML).
- Don't double-invert: set 6DOFtoUDP.py neutral and use the GUI, or vice-versa.
- Only one process can bind a UDP port; if 4242 is taken, change PORT in both places.
- Click a controller row to load it into the panel.

## Audit pass 2 fixes
- Editing the IP now takes effect live (listener tracks BoundAddress; Reconcile
  rebinds on IP *or* port change), not just on enable/disable.
- All GUI invert checkboxes now DEFAULT OFF so they don't compound with the
  inverts already in your 6DOFtoUDP.py (which would flip pitch/roll/Y the wrong way).
- A failed UDP bind (e.g. port already in use) is now reported once in the Log tab
  instead of failing silently.

## Verified end-to-end
- Listener parses the script's 48-byte format -> per-slot Global.headTracking[].
- GUI panel (IP / Port / Mode dropdown / 6 invert boxes) two-way binds to that
  same per-controller object; ControlService reads it live.
- HijackGyro overrides gyro at the device source BEFORE the motion event for all
  five device families (DS4, DualSense, DS3, Switch Pro, JoyCon); stale -> zeroed.
- MapToRightStick / MapToLeftStick drive the chosen stick.

## Still required by YOU for hijack to do something visible
Set the profile's gyro OUTPUT (Profiles tab) to Mouse or Joystick. Hijacking the
gyro only changes the gyro signal; if gyro output is "None", nothing uses it.
