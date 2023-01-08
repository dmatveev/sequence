Class {
	#name : #SeqPriorityRRSchedulerTest,
	#superclass : #TestCase,
	#instVars : [
		'sched'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqPriorityRRSchedulerTest >> setUp [ 
	super setUp.
	sched := SeqPriorityRRScheduler new.
]

{ #category : #tests }
SeqPriorityRRSchedulerTest >> testDecide [
	| block1 block2 sm1 sm2 pick |
	
	block1 := 'A' asSeqBlock.
	block2 := 'B' asSeqBlock.
	
	sm1 := SeqEventStreamMock new.
	sm2 := SeqEventStreamMock new.
	
	sm1 blockToWork: block1; nextTick: 5 ms; priority: 24.
	sm2 blockToWork: block2; nextTick: 5 ms; priority: 8.

	"EVEN without specifying a target, in such scenario most prioritized stream
	should win. As the each of the #blockToWork has its own target, on the next
	#decide: the other block should be selected.
	TODO: maybe test this, too"

   pick := sched decide: { sm1. sm2 }.
   self assert: pick identicalTo: sm1.
]
