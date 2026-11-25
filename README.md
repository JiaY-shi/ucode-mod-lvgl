# ucode-mode-lvgl

An LVGL binding for [ucode](https://github.com/jow-/ucode), so a user interface
for a small DRM display can be written in ucode rather than in C. It builds one
file, lv.so, which ucode loads as the module lv.

It carries the widgets, the DRM backend and the evdev input. Beside the binding
sits a panel library in ucode, shared by the applications built on it, with the
Inter faces and the icons that library draws.

## The panel library

`ucode/lvgl/` installs to `/usr/share/ucode/lvgl/` and is imported through the
default search path, as `lvgl.<name>`:

* `theme`, `assets`, `layout`, `widget`, `threshold`, `rate` and
  `component.*`: the design, the faces, the geometry and the drawing.
* `page`, `loader`, `runtime`: the page framework, the page loader, and the
  backlight, idle lock and settings. An application names its uci config and its
  page directory with `runtime_init()` and `loader_init()`.
* `sampler` and `sources`: the source framework, and the clock, cpu, sysinfo,
  temp and weather sources. An application hands its own sources to
  `sampler_init()` beside these.

`assets/fonts/` and `assets/icons/` install to `/usr/share/lvgl/`. Application
specific artwork stays with the application.

### Board layout

The shared panel reads the optional `panel` object from `/etc/board.json` when
its modules load. On OpenWrt, add it alongside the board's other settings.
If the boot splash runs before OpenWrt generates the file, include it in the
firmware image. Restart the application after changing the file. Omitted or
invalid fields fall back to the library defaults, including the 320×240 canvas.

For example, a GL-VB7200BE with a native 172×320 display can use:

```json
{
  "panel": {
    "display": { "width": 172, "height": 320 },
    "layout": {
      "header": {
        "subpage_left": 38,
        "right_inset": 44,
        "subpage_right_inset": 10,
        "count_width": 22
      },
      "fonts": { "header": "inter_semibold_15" },
      "dots": { "gap": 9 },
      "dialog": { "inset": 8 }
    }
  }
}
```

`display.width` and `display.height` describe the logical canvas in pixels
and should match the LVGL display. The optional `display.orientation` accepts
`landscape` or `portrait` and defaults to the aspect ratio of the canvas.
It selects layout defaults, such as placing gauge captions below their rings
on a portrait display. Display rotation is handled by the display backend.

Layout values are integer pixels. The sections and supported keys are:

| Section | Keys |
| --- | --- |
| `card` | `padding`, `radius`, `separator`, `bottom`, `rule_inset` |
| `group` | `inset`, `radius` |
| `header` | `top`, `left`, `bottom`, `subpage_left`, `right_inset`, `subpage_right_inset`, `count_width`, `count_gap`, `count_bottom` |
| `lock` | `right`, `top`, `hit_size` |
| `back` | `size`, `left`, `top`, `icon_x` |
| `dots` | `size`, `gap` (centre to centre), `bottom` |
| `row` | `height`, `root_height`, `padding`, `gap`, `line_gap`, `status_size`, `icon_slot`, `accessory_gap` |
| `keylist` | `row_height`, `title_top`, `line_gap` |
| `dialog` | `inset`, `radius`, `padding`, `bottom`, `gap`, `button_padding` |
| `switch` | `width`, `height`, `knob_size`, `knob_padding` |
| `signal` | `bar_width`, `gap`, `height_step` |
| `chart` | `gap`, `radius`, `min_bar_height` |
| `gauge` | `size`, `stroke`, `gap`, `edge`, `direction` (`row` or `column`) |
| `qr` | `size`, `padding`, `radius`, `caption_gap` |
| `typography` | `tracking` |

`layout.fonts` maps text roles to binary font filenames in
`/usr/share/lvgl/fonts/`, with the `.bin` suffix omitted. The roles are
`header`, `header_count`, `empty`, `row_title`, `row_detail`,
`root_row_title`, `root_row_detail`, `stacked_caption`, `stacked_value`,
`stacked_small_value`, `keylist_title`, `keylist_two_line_title`,
`keylist_detail`, `dialog_title`, `dialog_body`, `dialog_button`,
`gauge_caption` and `gauge_reading`. The theme measures the configured fonts
when computing header, row and dialog geometry.

## What it gives ucode

* Widgets: object, label, bar, chart, arc, line, tileview, image, qrcode. Each
  answers a handle carrying the methods in widget_fns[].
* A DRM display and an evdev pointer, both opened by path.
* Up to four evdev keypads with lv.indev_keypad(path, keymap), which maps
  input event codes onto LVGL keys, and lv.on_key(handler), which sees every
  key before the keymap does. Keys go to the focused widget of the active
  lv.group().
* lv.font_load(path) for an LVGL binary font, and lv.image_load(path, alpha)
  for a PNG as RGB565 or as an A8 coverage mask. Both answer an index and
  remember the paths they have already been given.
* lv.timer_handler() to drive from a uloop timer, and lv.refresh(), which
  draws and then waits for the panel to take the frame.
* lv.screenshot(path), so a page can be looked at without standing in front
  of it.

Every function a caller can reach carries a kernel-doc header in the source.

## Packaging

The OpenWrt package is ucode-mod-lvgl in
[feed-blogic](https://github.com/blogic/feed-blogic). It fetches LVGL, applies
the DRM patch, and builds this repository inside it.

## Licence

GPL-2.0-only, except the faces in `assets/fonts/`, which are Inter under the
SIL Open Font License 1.1 (`assets/fonts/OFL.txt`).
