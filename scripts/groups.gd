class_name Groups

const CARD_PILES: StringName = "card_piles"

const CELLS: StringName = "cells"
const EMPTY_CELLS: StringName = "empty_cells"
const NON_EMPTY_CELLS: StringName = "non_empty_cells"
const FULL_CELLS: StringName = "full_cells"

const FOUNDATIONS: StringName = "foundations"
const EMPTY_FOUNDATIONS: StringName = "empty_foundations"
const NON_EMPTY_FOUNDATIONS: StringName = "non_empty_foundations"
const FULL_FOUNDATIONS: StringName = "full_foundations"

const CASCADES: StringName = "cascades"
const EMPTY_CASCADES: StringName = "empty_cascades"
const NON_EMPTY_CASCADES: StringName = "non_empty_cascades"
const FULL_CASCADES: StringName = "full_cascades"

const DRAGGING_CARDS: StringName = "dragging_cards"
const MOVING_CARDS: StringName = "moving_cards"


static func empty(group: StringName) -> StringName:
	return "empty_" + group


static func non_empty(group: StringName) -> StringName:
	return "non_empty_" + group


static func full(group: StringName) -> StringName:
	return "full_" + group
