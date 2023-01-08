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
	| sm1 sm2 pick |
	
	sm1 := SeqEventStreamMock new.
	sm2 := SeqEventStreamMock new.
	
	sm1 nextTick: 5 ms.
	sm2 nextTick: 5 ms.
	
   "Win32: 0 (idle/lowest) to 31 (realtime/highest)".
   "BTW scheduder doesn't care, only order matters"
   sm1 priority: 8.
   sm2 priority: 24.

   pick := sched decide: { sm1. sm2 }.
   self assert: pick identicalTo: sm2.	 
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
