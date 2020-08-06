Class {
	#name : #SeqTarget,
	#superclass : #Object,
	#instVars : [
		'lanes',
		'execLanes',
		'lockedLanes'
	],
	#category : #Sequence
}

{ #category : #modelling }
SeqTarget >> events [
	"Return events from the 1st lane by default"
	^execLanes first events
]

{ #category : #initialization }
SeqTarget >> initialize [
	super initialize.
	 "Initialize with the default value. Not a simple assignment
	 due to extra execLanes initialization (see #lanes:)"
	self lanes: 1.
	lockedLanes := Dictionary new.
]

{ #category : #accessing }
SeqTarget >> lanes [
	^lanes
]

{ #category : #accessing }
SeqTarget >> lanes: aNumber [
	lanes := aNumber.
	
	"Immediately initialize execLanes here"
	execLanes := (1 to: aNumber) collect: [:i | SeqLane new]
]

{ #category : #scheduling }
SeqTarget >> release: aSeqBlock [ 
	(lockedLanes at: aSeqBlock) do: [ :each | each release: aSeqBlock ]
]

{ #category : #modelling }
SeqTarget >> tryLock: aSeqBlock at: aDuration [
	| toLock |
	"Check if this resource has room to execute this block..."
	toLock := (SeqAllocPolicy at: aSeqBlock allocPolicy) selectLanes: execLanes for: aSeqBlock lanes.
	toLock ifEmpty: [
		"Policy couldn't allocate anything"
		^false ].
	toLock do: [ :lane | lane lock: aSeqBlock at: aDuration ].
	lockedLanes at: aSeqBlock put: toLock.
	^true.
]
