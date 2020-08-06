Class {
	#name : #SeqLane,
	#superclass : #Object,
	#instVars : [
		'currentSeqBlock',
		'events',
		'currentLockTime'
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
SeqLane >> lock: aSeqBlock at: aDuration [ 
	currentSeqBlock := aSeqBlock.
	currentLockTime := aDuration.

]

{ #category : #sheduling }
SeqLane >> release: aSeqBlock [ 
	(aSeqBlock == currentSeqBlock) ifFalse: [ SeqInvalidRelease signal ].
	events add: (SeqEvent on: currentLockTime with: currentSeqBlock ).
	currentSeqBlock := nil.
	"TODO: A new entry to event log?"
]
