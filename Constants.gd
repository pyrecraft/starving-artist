extends Node

var DEBUG_MODE = false

enum State {
	PAINT,
	CONFIRM_CLEAR,
	CLEAR,
	STORE,
	CONFIRM_SELL,
	SELL
}

enum ConfirmBox {
	CLEAR,
	SELL
}