'use strict';

import * as lv from 'lv';
import { IMAGE_CHEVRON } from 'lvgl.assets';
import { layout } from 'lvgl.board';
import { C_SURFACE, C_RAISED, C_TXT, C_TXT_DIM, C_ACTION, GROUP_X, GROUP_W,
	 GROUP_RADIUS, ROW_PAD, ROW_GAP, SEP_H } from 'lvgl.theme';
import { icon_new } from 'lvgl.widget';

/*
 * A list whose rows take keyboard focus, the key driven counterpart to the
 * touch rows component. Each row is a focusable widget in the handle's group;
 * up and down move the focus, OK fires the row's handler. A chevron marks a row
 * that opens something.
 *
 * The caller owns the group and hands it in, because a screen's whole focus
 * order is one group, which may hold more than this one list.
 */

const geometry = layout.keylist;
const fonts = layout.fonts;
const CHEVRON = 24;

/**
 * keylist_new - a focusable list of rows
 * @parent: the screen, or a container on it
 * @group: the screen's focus group, from lv.group()
 * @opts: x, y, w for the geometry, w defaulting to the inset group width;
 *	  h, the most height the list takes; opacity, the card fill; row_h,
 *	  font, sub_font and sub_colour, for rows larger than the default
 *
 * Return: a handle carrying obj, the group surface, and set().
 */
export function keylist_new(parent, group, opts) {
	let o = opts ?? {};
	let list = { rows: [] };
	let row_h = o.row_h ?? geometry.row_height;
	let width = o.w ?? GROUP_W;
	let pad = min(ROW_PAD, max(0, int((width - 1) / 2)));

	let surface = lv.obj(parent);

	surface.set({ x: o.x ?? GROUP_X, y: o.y ?? 0, w: width });
	surface.style({ bg_color: C_SURFACE, bg_opa: o.opacity ?? lv.OPA_COVER,
			radius: GROUP_RADIUS, border_width: 0, pad_all: 0,
			clip_corner: true });
	surface.scrollable(true);
	surface.scroll_dir(lv.DIR_VER);
	surface.scrollbar(lv.SCROLLBAR_OFF);
	surface.clickable(false);

	list.obj = surface;

	/**
	 * set - build the rows from a list of items
	 * @items: one per row, each of label, and optionally secondary, chevron
	 *	   and on_ok
	 *
	 * The surface grows to the rows, bounded by its own height where the
	 * caller set one, and a focused row scrolls into view by itself.
	 */
	list.set = function(items) {
		surface.clean();
		list.rows = [];

		let count = length(items);
		let top = 0;

		for (let i = 0; i < count; i++) {
			let item = items[i];
			let row = lv.obj(surface);

			row.set({ x: 0, y: top, w: width, h: row_h });
			row.style({ bg_opa: lv.OPA_TRANSP, border_width: 0,
				    pad_all: 0, radius: 0 });
			row.style({ bg_color: C_RAISED, bg_opa: lv.OPA_COVER },
				  lv.PART_MAIN | lv.STATE_FOCUSED);
			row.scrollable(false);
			row.flag('scroll_on_focus', true);

			let avail = max(1, width - 2 * pad -
					(item.chevron ? CHEVRON + ROW_GAP : 0));

			let label = lv.label(row);
			let font = o.font ?? (item.secondary != null
					      ? fonts.keylist_two_line_title : fonts.keylist_title);

			label.text(item.label);
			label.style({ text_color: C_TXT, text_font: font });

			if (o.font != null)
				label.long_mode(lv.LABEL_LONG_DOTS);

			if (item.secondary != null) {
				let sub_font = o.sub_font ?? fonts.keylist_detail;
				let font_h = lv.font_line_height(font);
				let label_y = geometry.title_top;

				if (o.font != null)
					label_y = int((row_h - font_h -
						       lv.font_line_height(sub_font)) / 2);

				label.set({ x: pad, y: label_y, w: avail });

				let sub = lv.label(row);

				sub.text(item.secondary);
				sub.style({ text_color: o.sub_colour ?? C_TXT_DIM,
					    text_font: sub_font });
				sub.set({ x: pad, w: avail,
					  y: label_y + font_h + (o.font != null ? 0 : geometry.line_gap) });

				if (o.font != null)
					sub.long_mode(lv.LABEL_LONG_DOTS);
			}
			else {
				label.set({ align: lv.ALIGN_LEFT_MID,
					    align_x: pad, w: avail });
			}

			if (item.chevron)
				icon_new(row, IMAGE_CHEVRON, C_ACTION)
					.set({ align: lv.ALIGN_RIGHT_MID,
					       align_x: -pad });

			if (item.on_ok)
				row.on(lv.EVENT_CLICKED, item.on_ok);

			group.add(row);
			push(list.rows, row);

			top += row_h;

			if (i + 1 < count) {
				let sep = lv.obj(surface);

				sep.set({ x: pad, y: top, w: width - 2 * pad,
					  h: SEP_H });
				sep.style({ bg_color: C_RAISED, bg_opa: lv.OPA_COVER,
					    border_width: 0, pad_all: 0, radius: 0 });
				sep.clickable(false);
				sep.scrollable(false);

				top += SEP_H;
			}
		}

		let room = o.h ?? (parent.height() - (o.y ?? 0));

		surface.set({ h: top > room ? room : top });

		if (length(list.rows))
			group.focus(list.rows[0]);
	};

	return list;
};
