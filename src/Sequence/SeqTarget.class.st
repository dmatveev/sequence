Class {
	#name : #SeqTarget,
	#superclass : #Object,
	#instVars : [
		'lanes',
		'execLanes',
		'lockedLanes',
		'name'
	],
	#category : #Sequence
}

{ #category : #modelling }
SeqTarget >> canLock: aSeqBlock [
	^(self lanesToLock: aSeqBlock) isNotEmpty
]

{ #category : #modelling }
SeqTarget >> canLock: aSeqBlock inContextOf: anEventStream managedBy: aScheduler [ 
	| lanesToLock |
	lanesToLock := self lanesToLock: aSeqBlock.

	"Sometimes having lanes to lock doesn't always mean those needs to be locked
	right now: a Scheduler may have an opinion on this"
	^ lanesToLock
		ifEmpty: [
			"NOTE: There's no resource right now for this process, but we don't wait list it here.
			The semantic of this function is _can_, not _try_. Process can waitlist itself if it can't lock
			or chose another option to chose. Let's not cut off this possible decision making"
			false. ]
		ifNotEmpty: [ 
			"If lanes are available, ask Scheduler if we should really allocate those for the block"
			aScheduler askLockOn: self for: anEventStream at: aSeqBlock ]

]

{ #category : #modelling }
SeqTarget >> events [
	"Return events from the 1st lane by default"
	^execLanes first events
]

{ #category : #accessors }
SeqTarget >> execLanes [
	^ execLanes
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

{ #category : #modelling }
SeqTarget >> lanesToLock: aSeqBlock [
	^(SeqAllocPolicy at: aSeqBlock allocPolicy) selectLanes: execLanes for: aSeqBlock lanes.
]

{ #category : #accessing }
SeqTarget >> name [
	^name
]

{ #category : #accessing }
SeqTarget >> name: aString [
	name := aString
]

{ #category : #scheduling }
SeqTarget >> release: aToken [
	(lockedLanes at: aToken) do: [ :each | each release: aToken seqBlock ].
	lockedLanes removeKey: aToken
]

{ #category : #modelling }
SeqTarget >> tryLock: aSeqBlock at: aDuration inContextOf: aFrame [
	| toLock token |
	"Check if this resource has room to execute this block..."
	toLock := self lanesToLock: aSeqBlock.
	toLock ifEmpty: [
		"Policy couldn't allocate anything"
		^nil ].
	toLock do: [ :lane | lane lock: aSeqBlock at: aDuration inContextOf: aFrame ].
	token := SeqLock with: aSeqBlock.
	lockedLanes at: token put: toLock.
	^token.
]
