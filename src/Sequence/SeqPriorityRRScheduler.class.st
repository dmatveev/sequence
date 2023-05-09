Class {
	#name : #SeqPriorityRRScheduler,
	#superclass : #SeqRoundRobinScheduler,
	#instVars : [
		'waitlist'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqPriorityRRScheduler >> askLockOn: aSeqTarget for: aSeqEventStream at: aSeqBlock [ 
	"The logic here must be simple:
	- A stream wants to lock a resource.
	- If there's no higher-priority streams wait-listed, let's give the permission.
	- Otherwise [...some more complex logic may be here...] reject -- keep it for the higher priority one"
	
	"NOTE: There may be also a stream of the same priority but waiting too long... It is not handled right now"
	| wl |
	wl := self waitlistOn: aSeqTarget.
		
	wl detect: [ :s | s priority > aSeqEventStream priority ]
		ifFound: [ :s | ^false ].
		
	"If this stream is itself in the waitlist, remove it"
	"FIXME: MAYBE this is not the right place to do that, since ask != actually lock"
	(wl includes: aSeqEventStream) ifTrue: [ wl remove: aSeqEventStream ].
	^true		
]

{ #category : #'as yet unclassified' }
SeqPriorityRRScheduler >> decide: aSortedCollectionOfStreams [
	"A scheduler poem.
	
	Here I stand, meed to pick one from multiple _parallel_ processes-candidates.
	First of all, where a scheduling problem occurs? It occurs when different process
	compete for the same resource. So if they don't compete at all.. Maybe its a simple
	case to handle?
	
	Our input is a sorted collection of streams, everybody ready to make its tick.
	And tick doesn't always mean acquiring a resource.. Sometimes it is actually releasing
	a resource -- see the SeqEventStream>>advance for details."
	| targetDemand earliest frontRow frontRowTop |
	
	"May be a short cut. If anybody here in the FRONT ROW wants to just
	RELEASE a resource, you are welcome. Regardless of your priority!"
	earliest := aSortedCollectionOfStreams first nextTick.
	frontRow := aSortedCollectionOfStreams select: [ :each | each nextTick = earliest ].
	frontRow do: [ :stream | stream wantsToLeave ifTrue: [ ^self markDecision: stream ]].
	
	"So nobody wants to release in the FRONT ROW.. 	Will have to figure out the resource situation.
	And what are our resources, anyway? Those are targets.
	And we need to see if there's any competition for a target."
	targetDemand := Dictionary new.
	frontRow do: [ :stream |
		stream blockToWork ifNotNil: [ :block |
			(targetDemand at: block target ifAbsentPut: [ OrderedCollection new ]) add: stream]].
	
	"Note there may be multiple targets under pressure.. We pick a stream at time anyway.
	Then we could revisit other occurences on the next tick. Or not (if situation changes
	after/due to this decision. Anyway...
	Take _any_ occurence. Just any. Then select using prioritization AND round-robin"
	targetDemand keysAndValuesDo: [ :target :candidates |
		(candidates size > 1) ifTrue: [ | topp |
			"Just select the highest-priority stream(s) and then round-robin between them"
			topp := (candidates collect: [ :each | each priority ]) max.
			^self markDecision: (self selectRR: (candidates select: [:each | each priority = topp])) ]	].
	
	"If reached here, it seems there was no occasion this time.
	NB: Priorities should be kept in mind here too."
	frontRowTop := (frontRow collect: [:each | each priority]) max.
	^self markDecision: (self selectRR: (frontRow select: [:each | each priority = frontRowTop])).
]

{ #category : #'as yet unclassified' }
SeqPriorityRRScheduler >> initialize [
	super initialize.
	waitlist := Dictionary new
]

{ #category : #'as yet unclassified' }
SeqPriorityRRScheduler >> waitlist: aSeqEventStream to: aSeqTarget [ 
	(self waitlistOn: aSeqTarget) add: aSeqEventStream
]

{ #category : #'as yet unclassified' }
SeqPriorityRRScheduler >> waitlistOn: aSeqTarget [
	^waitlist at: aSeqTarget ifAbsentPut:  [ Set new ]	
]
