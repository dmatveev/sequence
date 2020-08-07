Class {
	#name : #SeqLane,
	#superclass : #Object,
	#instVars : [
		'currentSeqBlock',
		'events',
		'currentLockTime',
		'currentFrame'
	],
	#category : #Sequence
}

{ #category : #modelling }
SeqLane >> events [
	^events
]

{ #category : #testing }
SeqLane >> initialize [
	super initialize.
	events := OrderedCollection new.
]

{ #category : #testing }
SeqLane >> isLocked [
	^currentSeqBlock isNotNil
]

{ #category : #scheduling }
SeqLane >> lock: aSeqBlock at: aDuration inContextOf: aFrame [
	currentSeqBlock := aSeqBlock.
	currentLockTime := aDuration.
	currentFrame := aFrame.

]

{ #category : #sheduling }
SeqLane >> release: aSeqBlock [ 
	(aSeqBlock == currentSeqBlock) ifFalse: [ SeqInvalidRelease signal ].
	"TODO: this trio of time/block/frame is exactly an Event...
	Probably I should use this object everywhere"
	events add: (SeqEvent on: currentLockTime with: currentSeqBlock inContextOf: currentFrame ).
	currentSeqBlock := nil.
]
