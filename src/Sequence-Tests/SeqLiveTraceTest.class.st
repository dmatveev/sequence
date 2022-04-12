Class {
	#name : #SeqLiveTraceTest,
	#superclass : #TestCase,
	#instVars : [
		'trace',
		'cam',
		'proc'
	],
	#category : #'Sequence-Tests'
}

{ #category : #initialization }
SeqLiveTraceTest >> setUp [
	super setUp.
	cam := 'Camera' asSeqBlock latency: 33 ms; live.
	proc := 'Process' asSeqBlock latency: 2 ms.
	cam >> proc.
	trace := (Sequence startingWith: cam) runFor: 50 ms using: SeqNaiveExecutor.
]

{ #category : #initialization }
SeqLiveTraceTest >> testInvocations [
	| ev1 ev2|
	ev1 := cam target events.
	ev2 := proc target events.
	self assert: ev1 size equals: 2. "Should complete only 1 camera block in 50ms. FIXME: The execution loop allows the 2nd frame to complete"
	self assert: (ev1 allSatisfy: [:each | each seqBlock == cam]).
	self assert: ev2 size equals: 1. "Should complete only 1 processing block in 50ms"
	self assert: (ev2 allSatisfy: [:each | each seqBlock == proc]).
	
]
