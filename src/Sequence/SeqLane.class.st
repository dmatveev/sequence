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

{ #category : #rendering }
SeqLane >> allLive [
	^ events
		ifEmpty: [ false ]
		ifNotEmpty: [ events allSatisfy: [ :each | each seqBlock isLive ]]
]

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
   | ev |
	(aSeqBlock == currentSeqBlock) ifFalse: [ SeqInvalidRelease signal ].
	"TODO: this trio of time/block/frame is exactly an Event...
	Probably I should use this object everywhere"
	ev := SeqEvent on: currentLockTime with: currentSeqBlock inContextOf: currentFrame.
	"TODO: One more thing: this is a duplication of information from #runFor"
	ev duration: (aSeqBlock durationOn: currentFrame).
	ev lane: self.
	events add: ev.
	currentSeqBlock := nil.
]

{ #category : #rendering }
SeqLane >> utilization [
	| total running |
	"Lane utilization is a ratio of time running to the overall execution time.
	FIXME: the total time must be taken Sequence-wide!"
	events isEmptyOrNil ifTrue: [^0.0 ]. 

	total := events last endTime.
	running := (events collect: #duration) sum.
	^ (running / total) asFloat
]
