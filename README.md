<div align="center">

# 🎯 OSIRIS Tracking
### DS4Windows, but your **head** is the gyro.

A fork of [DS4Windows](https://github.com/schmaldeo/DS4Windows) that streams **VR headset motion over UDP** straight into your controller's gyro — so any game with gyro aiming now follows your head.

![Platform](https://img.shields.io/badge/platform-Windows%2010%2B-0078D6?logo=windows&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet&logoColor=white)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Built on](https://img.shields.io/badge/built%20on-DS4Windows-red)

</div>

---

## ✨ What is this?

Normal DS4Windows reads your controller and re-sends it to Windows as a virtual Xbox/DS4 pad — gyro included. **OSIRIS Tracking** adds a small UDP listener that lets a VR headset (or anything that can send head pose) **replace** that gyro signal at the source.

The replacement happens *inside the controller's motion pipeline*, before anything reads it — so the gyro mouse, gyro stick, motion server, and on-screen readouts all see the **headset** as the controller's native gyro. It's not a hack bolted on the end; as far as the app is concerned, your head **is** the controller's motion.

It works with **DualShock 4, DualSense / DualSense Edge, DualShock 3, Switch Pro, and JoyCons**.

---

## 🚀 Quick Start — make gyro follow your head

You need two things talking to each other: a **sender** (your VR app) and **OSIRIS Tracking** (the listener).

### 1️⃣ Start the head-pose sender
Run the included **`6DOFtoUDP.py`** script in **VRCompanion**. It streams your head pose (yaw/pitch/roll + position) over UDP in OpenTrack format. By default it sends to `127.0.0.1:4242`.

### 2️⃣ Configure OSIRIS Tracking
Open OSIRIS, go to the **Controllers** tab, and find the red **`OSIRIS TRACKING (UDP)`** panel under your controller:

1. ✅ **Enable head tracking**
2. 🌐 **Listen IP / Port** → match the script (`127.0.0.1` / `4242`)
3. 🎛️ **Mode** → **`HijackGyro`**

### 3️⃣ ⚠️ Tell the profile to *use* the gyro (the step everyone misses)
Hijacking the gyro only changes the **signal** — something has to consume it. Go to:

> **Profiles → Edit → Gyro / Motion**, and set the gyro output to **Mouse** (for aiming) or **Joystick / Stick**.

If gyro output is set to **None**, you'll see no effect. This is the #1 "why isn't it working" cause.

### 4️⃣ Tune & play
Adjust the **Speed / sensitivity** sliders and **Gyro scale**, flip an **Invert** box if an axis goes the wrong way, and you're tracking. 🎮

---

## 🧩 Features

| | Feature | What it does |
|---|---------|--------------|
| 🎯 | **Hijack Gyro** | Head rotation fully replaces the controller's gyro, at the device source. |
| 🕹️ | **Map → Right / Left Stick** | Head orientation drives a thumbstick instead of the gyro. |
| 📐 | **Position → Accelerometer** | Optional toggle: head *lean* (X/Y/Z) feeds the accelerometer, activating those axes. |
| 🎚️ | **Per-axis Speed sliders** | Fine `0.00–1.00` sensitivity for Yaw/Pitch/Roll and X/Y/Z (0.01 steps). |
| 🔁 | **Invert axes** | Flip any axis that points the wrong way. |
| 🛰️ | **Live UDP listener** | Edit IP/port on the fly; reports a busy port in the Log tab. |
| 🛡️ | **Fail-safe** | If the head feed stalls, the gyro is zeroed so your aim never jumps. |
| 🧰 | **Everything DS4Windows does** | Profiles, output remapping, lightbar, rumble, the DSU motion server, and more. |

---

## ⚙️ Panel Reference

| Setting | Meaning |
|--------|---------|
| **Enable head tracking** | Master on/off for this controller. |
| **Listen IP / Port** | Where OSIRIS listens for head data. Must match your sender. |
| **Mode** | `Off`, `HijackGyro`, `MapToRightStick`, `MapToLeftStick`. |
| **Stick range (deg)** | Map modes: head degrees that equal full stick deflection. |
| **Gyro scale** | Overall multiplier on top of the speed sliders — raise it to amplify beyond 1:1. |
| **Speed / sensitivity** | Per-axis fine balance (0–1). |
| **Position → accelerometer** | Makes the X/Y/Z sliders active. |
| **Invert axes** | Per-axis direction flip. |

> 💡 **Don't double-invert.** `6DOFtoUDP.py` already inverts pitch/roll/Y. The in-app invert boxes default **off** so they don't fight the script — flip one only if an axis is still wrong, or set the script neutral and drive it all from here.

> 🔌 **One app per port.** Only one program can bind a UDP port. If `4242` is taken (e.g. OpenTrack), pick a different port in **both** the script and the panel.

---

## 🛠️ Build from source

**Requirements:** Windows 10+, the [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0). To *run* the result you also need the **.NET 8 Desktop Runtime** + **[ViGEmBus](https://vigem.org/)** (same as DS4Windows).

```bat
:: from the repo root
build.bat
```

The build lands at **`build\DS4Windows.exe`**.

---

## 🙏 Credits

OSIRIS Tracking stands entirely on the shoulders of the people who built and maintained DS4Windows. Huge thanks to:

- **[Ryochan7](https://github.com/Ryochan7)** and **[Jays2Kings](https://github.com/Jays2Kings)** — the original DS4Windows. None of this exists without their years of work. ❤️
- **[schmaldeo](https://github.com/schmaldeo/DS4Windows)** — the "DS4Windows but improved" fork this is based on.
- **sunnyqeen** — accelerometer pitch/roll work in the upstream project.
- The **VRCompanion** / **OpenTrack** community for the head-tracking protocol, and **itsloopyo** for the head-tracking mod the sender script was written for.

This project only *adds* the head-tracking layer — all the heavy lifting underneath is theirs.

---

## 📜 License

Released under the **GNU General Public License v3.0**, same as DS4Windows. See [`LICENSE.txt`](LICENSE.txt).

<div align="center">

*Made for people who'd rather look where they aim.* 🎯

</div>
