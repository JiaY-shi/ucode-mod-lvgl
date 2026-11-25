'use strict';

import * as lv from 'lv';
import { display, layout } from 'lvgl.board';

/*
 * A name says what a colour is for, not what it looks like. Nine of the sixteen
 * are neutral, because the panel is mostly type on glass.
 *
 * Values one or two steps apart in RGB565 are the same colour on this display,
 * so a shade only earns a name where it carries a different meaning.
 */

export const C_SCREEN	= 0x000000;
export const C_SURFACE	= 0x1c1c1e;
/* A surface lifted off the one beneath: a pressed row, the back circle, a
   dialog over its scrim. Without haptics the pressed step is the only
   affordance a row has, so it is a step of fill and not an animation. */
export const C_RAISED	= 0x2c2c2e;

/* Present but inactive: the off track of a switch, an unlit page dot. A
   different idea from the structural C_RULE, and a step darker. */
export const C_IDLE	= 0x3e3e44;
/* Down rather than merely inactive: a status dot that is off, and the hairline
   inside a dialog, which sits on C_RAISED and needs more than C_IDLE. */
export const C_DOWN	= 0x48484a;

/* Everything structural: the line between rows, the unfilled part of a gauge,
   a count beside a title. Two steps up the iOS dark grey ladder from 0x38383a,
   because a single pixel of anything darker is invisible on this glass. */
export const C_RULE	= 0x636366;

/* Type takes two tiers and no more. White names the thing; the dim tier carries
   what qualifies it, and a mark at full brightness is white like a word. */
export const C_TXT	= 0xffffff;
export const C_TXT_DIM	= 0x9a9aa2;

/* The filled part of the brightness bar. Not pure white: the bar is a control
   and would otherwise read as a lit panel rather than a thing to drag. */
export const C_FILL	= 0xe8e8ec;

/* Two series, which tell one line from another and never mean quality. */
export const C_SERIES	= 0x0a6cff;
export const C_SERIES_ALT = 0x64d2ff;
/* A third and separate idea, close to C_SERIES and never drawn beside it: this
   one means touchable. */
export const C_ACTION	= 0x0a84ff;

/* State. Colour carries meaning, never decoration, and normally sits beside a
   word saying the same thing. Good needs no colour. */
export const C_OK	= 0x32d74b;
export const C_WARN	= 0xff9f0a;
export const C_ALERT	= 0xff453a;

export const W		= display.width;
export const H		= display.height;

/* Cards are full bleed: they meet the top and both sides of the glass, and only
   the bottom is held back, to clear the page dots. */
export const CARD_X	= 0;
export const CARD_W	= W;
export const CARD_PAD	= min(layout.card.padding, int((CARD_W - 1) / 2));
export const CARD_RADIUS = layout.card.radius;
export const SEP_H	= layout.card.separator;

/* Negative tracking, which the display sizes of Inter want and the small ones do not. */
export const TRACK_SPACE = layout.typography.tracking;

/*
 * The v3 grid. A list group is inset from both edges and rounded, unlike the
 * full bleed cards above it, because a list of rows reads as one object sitting
 * on the glass rather than as the glass itself.
 */
export const GROUP_X	= min(layout.group.inset, int((W - 1) / 2));
export const GROUP_W	= W - 2 * GROUP_X;
export const GROUP_RADIUS = layout.group.radius;

/*
 * Root rows are read at a distance and use a larger tier. Subpages pack more
 * detail into the same space. The separator ends where the text starts.
 */
export const ROW_H	= layout.row.height;
export const ROW_H_ROOT	= layout.row.root_height;
export const ROW_PAD	= min(layout.row.padding, int((GROUP_W - 1) / 2));
export const ROW_GAP	= layout.row.gap;

/*
 * The header does not scroll. v3 had it as the first item of the scroll
 * content, which reads well on a phone and badly here: on a 240 px panel the
 * page loses the only thing naming it as soon as the list moves, and the back
 * circle would go with it. Header and back stay put; only the payload scrolls.
 */
export const HEAD_TOP	= layout.header.top;
export const HEAD_X	= layout.header.left;
export const HEAD_BOTTOM = layout.header.bottom;
export const HEAD_INDENT = layout.header.subpage_left;
export const HEAD_FONT	= layout.fonts.header;

/*
 * The lock sits opposite the header on every page that can be left, and is the
 * way out: it puts the panel back to idle at once, which with a PIN set means
 * the next person has to enter it. The icon is small, so the hit area is not.
 */
export const LOCK_SIZE	= 14;	/* Width of the bundled lock image. */
export const LOCK_X	= W - layout.lock.right - LOCK_SIZE;
export const LOCK_Y	= layout.lock.top;
export const LOCK_HIT	= layout.lock.hit_size;

/* The back circle floats over the content rather than sitting in a bar. */
export const BACK_SIZE	= layout.back.size;
export const BACK_X	= layout.back.left;
export const BACK_Y	= layout.back.top;

/* Page dots, roots only. */
export const DOT_SIZE	= layout.dots.size;
export const DOT_GAP	= layout.dots.gap;
export const DOT_BOTTOM	= layout.dots.bottom;

/*
 * Both stop the same distance above the bottom of the glass. A root spends that
 * strip on its dot row and a sub page leaves it empty, but a card that ran to
 * the edge on one and not on the other would read as a mistake, and the rounded
 * foot that says where a list ends would be off screen on the sub page.
 */
export const LIST_H	= max(1, H - layout.card.bottom);
export const LIST_H_SUB	= LIST_H;

/*
 * The header is as tall as the face it is set in, read from the face itself
 * rather than copied out of it, so it cannot drift when the fonts are cut
 * again. Regenerating the set once already moved every line height by a pixel.
 */
export const HEAD_H	= HEAD_TOP + lv.font_line_height(HEAD_FONT) + HEAD_BOTTOM;

/*
 * The strip a page draws into, under the fixed header. Nine pages held back
 * five different amounts from the bottom of the glass for what is one region,
 * so there is one of it here and none of them keeps its own.
 */
export const BODY_Y	= HEAD_H;
export const BODY_H	= max(1, LIST_H - HEAD_H);

/*
 * A rule drawn across a page that has no card. The separator inside a group is
 * a different idea and keeps its own inset, which is left aligned only.
 */
export const RULE_PAD	= layout.card.rule_inset;

/*
 * The weather page. The sky glyphs are the one thing on the panel that is not
 * text, a reading or a state, so they carry their own tint: white would make
 * them read as another label and the interactive blue would say they can be
 * tapped.
 */
export const C_SKY	= 0xc9d4ff;
