// SPDX-License-Identifier: GPL-2.0-only
'use strict';

import { readfile } from 'fs';
import { face } from 'lvgl.assets';

const defaults = {
	card: { padding: 10, radius: 12, separator: 1, bottom: 12, rule_inset: 14 },
	group: { inset: 10, radius: 9 },
	header: {
		top: 11, left: 12, bottom: 7, subpage_left: 40,
		right_inset: 0, subpage_right_inset: 0,
		count_width: 0, count_gap: 5, count_bottom: 2
	},
	lock: { right: 12, top: 15, hit_size: 44 },
	back: { size: 28, left: 6, top: 6, icon_x: -1 },
	dots: { size: 5, gap: 10, bottom: 5 },
	row: {
		height: 48, root_height: 60, padding: 11, gap: 9, line_gap: 1,
		status_size: 7, icon_slot: 22, accessory_gap: 5
	},
	keylist: { row_height: 44, title_top: 5, line_gap: 1 },
	dialog: { inset: 34, radius: 13, padding: 15, bottom: 13, gap: 5, button_padding: 10 },
	switch: { width: 38, height: 22, knob_size: 18, knob_padding: 2 },
	signal: { bar_width: 3, gap: 2, height_step: 3 },
	chart: { gap: 2, radius: 1, min_bar_height: 2 },
	gauge: { size: 72, stroke: 5, gap: 10, edge: 20 },
	qr: { size: 112, padding: 10, radius: 6, caption_gap: 10 },
	typography: { tracking: -2 }
};

const font_defaults = {
	header: 'inter_semibold_21',
	header_count: 'inter_regular_13',
	empty: 'inter_regular_13',
	row_title: 'inter_regular_13',
	row_detail: 'inter_regular_11',
	root_row_title: 'inter_regular_15',
	root_row_detail: 'inter_regular_13',
	stacked_caption: 'inter_regular_11',
	stacked_value: 'inter_regular_12_tnum',
	stacked_small_value: 'inter_regular_10_tnum',
	keylist_title: 'inter_regular_20',
	keylist_two_line_title: 'inter_regular_15',
	keylist_detail: 'inter_regular_13',
	dialog_title: 'inter_semibold_15',
	dialog_body: 'inter_regular_11',
	dialog_button: 'inter_regular_15',
	gauge_caption: 'inter_regular_15',
	gauge_reading: 'inter_semibold_15'
};

function object_or_empty(value) {
	return type(value) == 'object' ? value : {};
}

function read_panel() {
	let data = readfile('/etc/board.json');

	if (!data)
		return {};

	try {
		let board = object_or_empty(json(data));

		return object_or_empty(board.panel);
	}
	catch (e) {
		return {};
	}
}

function pixels(value, fallback, minimum) {
	return type(value) == 'int' && value >= minimum && value <= 32767
		? value : fallback;
}

function choice(value, choices, fallback) {
	return type(value) == 'string' && index(choices, value) >= 0 ? value : fallback;
}

const panel = read_panel();
const display_config = object_or_empty(panel.display);
const width = pixels(display_config.width, 320, 1);
const height = pixels(display_config.height, 240, 1);

export const display = {
	width, height,
	orientation: choice(display_config.orientation, [ 'landscape', 'portrait' ],
			    width < height ? 'portrait' : 'landscape')
};

function layout_from(config) {
	let layout = {};
	let portrait = display.orientation == 'portrait';

	for (let section, fields in defaults) {
		let overrides = object_or_empty(config[section]);
		let base = portrait && section == 'gauge' ? { ...fields, gap: 4, edge: 0 } : fields;
		let values = {};

		for (let key, fallback in base) {
			let minimum = fallback < 0 ? -32767 : 0;

			values[key] = pixels(overrides[key], fallback, minimum);
		}

		layout[section] = values;
	}

	let gauge = object_or_empty(config.gauge);
	let fonts = object_or_empty(config.fonts);

	layout.gauge.direction = choice(gauge.direction, [ 'row', 'column' ],
					portrait ? 'column' : 'row');

	layout.fonts = {};

	for (let key, fallback in font_defaults) {
		let name = fonts[key];
		let font = null;

		if (type(name) == 'string' && match(name, /^[a-zA-Z0-9_-]+$/))
			font = face(name);

		layout.fonts[key] = font ?? face(fallback);
	}

	return layout;
}

export const layout = layout_from(object_or_empty(panel.layout));
