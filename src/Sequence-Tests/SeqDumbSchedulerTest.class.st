Class {
	#name : #SeqDumbSchedulerTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqDumbSchedulerTest >> testDecide [
	"The dumb scheduler always decides for the first element in the collection"
	| sched |
	sched := SeqDumbScheduler new.
	self assert: (sched decide: #(1 2 3)) equals: 1.
	self assert: (sched decide: #(9 1 2)) equals: 9.
]
