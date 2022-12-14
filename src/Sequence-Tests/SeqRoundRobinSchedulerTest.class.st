Class {
	#name : #SeqRoundRobinSchedulerTest,
	#superclass : #TestCase,
	#instVars : [
		'sched'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqRoundRobinSchedulerTest >> setUp [ 
	super setUp.
	sched := SeqRoundRobinScheduler new.
]

{ #category : #tests }
SeqRoundRobinSchedulerTest >> testDecide [
	"If there's multiple options to choose from, the round robin scheduler
	chooses the least executed one.
	
	Note: right now Scheduler expects #nextTick to be implemented by the stream..
	Probably that's an abstraction leak and we need to feed the scheduler with #nextTick-selected
	options by default?"
	| sm1 sm2 sm3 picks tick |
	sm1 := SeqEventStreamMock new.
	sm2 := SeqEventStreamMock new.
	sm3 := SeqEventStreamMock new.
	picks := Set new.

	tick := [ :x || p |
		sm1 nextTick: x.
		sm2 nextTick: x.
		sm3 nextTick: x.
		p := sched decide: { sm1. sm2. sm3 }.
		picks add: p.
		self assert: (sched decisions: p) equals: 1.
		p].

	tick value: 0 ms. "Should pick a single sequence (any of them)"
	self assert: picks size equals: 1.
	
	tick value: 1 ms. "Should pick another sequence!"
	self assert: picks size equals: 2.
	
	tick value: 2 ms. "Should pick another sequence (again!)"
	self assert: picks size equals: 3.
	
	"Now see if it choses the only option"
	sm1 nextTick: 3 ms.
	(sched decide: {sm1}) ifNotNil: [ :pick | self assert: (sched decisions: pick) equals: 2 ].
]

{ #category : #tests }
SeqRoundRobinSchedulerTest >> testMarkDecision [
	"By default, there's no decisions per stream."
	self assert: (sched decisions: 1) equals: 0.
	
	"Once marked, the counter for a stream increments."
	sched markDecision: 1.
	self assert: (sched decisions: 1) equals: 1.
	
	"Mark again to double-check."
	sched markDecision: 1.
	self assert: (sched decisions: 1) equals: 2.
]
