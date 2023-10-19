Class {
	#name : #SeqTarget,
	#superclass : #Object,
	#instVars : [
		'lanes',
		'execLanes',
		'lockedLanes',
		'name',
		'waitlist',
		'incubator'
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

{ #category : #'as yet unclassified' }
SeqTarget >> confirm: aStream [
	waitlist removeKey: aStream ifAbsent: [ 
		"Do nothing, it is OK if there's no stream in the
		waitlist - probably it wasn't waitlisted at all
		(no resource contention).
		FIXME: MAYBE this is the point where incubator needs
		to be updated. Right now it happens in #waitlist and
		sort-of duplicates it the waitlist itself to some
		extent" ].
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
	
	"Lanes which are currently locked.
	SeqToken -> Array of Lanes"
	lockedLanes := Dictionary new.
	
	"Waitlist is a dictionary:
	EventStream* -> the time point it was first waitlisted
	*(FIXME: whoah, we know about streams here!)"
	waitlist := Dictionary new.
	
	"Incubator holds information about events which are ready to start,
	but can't due to resource contention.
	EventStream -> waitlist time."
	incubator := Dictionary new.
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
	| events |
	events := (lockedLanes at: aToken) collect: [ :each | each release: aToken seqBlock ].
	lockedLanes removeKey: aToken.
	^events
]

{ #category : #scheduling }
SeqTarget >> release: aToken in: aSeqStream [
	"FIMXE: Whoah. We know about SeqStream again"
	| events |
	events := self release: aToken.
	incubator
		at: aSeqStream
		ifPresent: [ :waitlisted |
			events do: [ :each | each readyToStartTime: waitlisted ].
			incubator removeKey: aSeqStream. ]	
]

{ #category : #modelling }
SeqTarget >> tryLock: aSeqBlock at: aDuration inContextOf: aFrame [
	| toLock token |
	"Check if this resource has room to execute this block..."
	toLock := self lanesToLock: aSeqBlock.
	toLock ifEmpty: [
		"Policy couldn't allocate anything"
		^nil ].
	
	"Confirm the lock."
	toLock do: [ :lane | lane lock: aSeqBlock at: aDuration inContextOf: aFrame ].
	token := SeqLock with: aSeqBlock.
	lockedLanes at: token put: toLock.
	
	"Waitlist should've been updated here as well, but this method
	has no proper way to identify which stream to de-waitlist based
	on thisContext. So, instead, there's an ugly #confirm: which now
	is sent as a follow-up"
	
	^token.
]

{ #category : #'as yet unclassified' }
SeqTarget >> waitlist [
	^waitlist
]

{ #category : #'as yet unclassified' }
SeqTarget >> waitlist: aSeqEventStream [ 
	| now |
	now := aSeqEventStream currentTime.
	
	waitlist 
		at: aSeqEventStream
		update: [ :t | t min: now ]
		initial: [ 
			"Probably not the best use of #initial but it works..
			Use this point to create an incubator event."
			incubator at: aSeqEventStream put: now. 
			now ]
]
