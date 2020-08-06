Class {
	#name : #SeqTraceTest,
	#superclass : #TestCase,
	#instVars : [
		'trace'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqTraceTest >> setUp [
	| cam proc |
	super setUp.
	cam := 'Camera' asSeqBlock.
	proc := 'Process' asSeqBlock.
	cam >> proc.
	trace := (SeqScene startingWith: cam) runFor: 5 seconds.
]

{ #category : #running }
SeqTraceTest >> testTargets [
	self assert: trace targets size equals: 2
]
