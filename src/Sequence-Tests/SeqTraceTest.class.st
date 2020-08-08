Class {
	#name : #SeqTraceTest,
	#superclass : #TestCase,
	#instVars : [
		'trace',
		'cam',
		'proc'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqTraceTest >> setUp [
	super setUp.
	"20ms is unusual for Camera, but convenient for testing"
	cam := 'Camera' asSeqBlock latency: 20 ms.
	proc := 'Process' asSeqBlock latency: 5 ms.
	cam >> proc.
	trace := (Sequence startingWith: cam) runFor: 5 seconds using: SeqNaiveScheduler.
]

{ #category : #running }
SeqTraceTest >> testInvocations [
	| ev1 ev2|
	ev1 := cam target events.
	ev2 := proc target events.
	"Magic number 5*40 is 5 seconds with 40 FPS"
	self assert: ev1 size equals: (5*40).
	self assert: (ev1 allSatisfy: [:each | each seqBlock == cam]).
	self assert: ev2 size equals: (5*40).
	self assert: (ev2 allSatisfy: [:each | each seqBlock == proc]).
	
]

{ #category : #running }
SeqTraceTest >> testNumFrames [
	"Magic number 5*40 is 5 seconds with 40 FPS"
	self assert: trace numFrames equals: (5*40)
]

{ #category : #running }
SeqTraceTest >> testTargets [
	self assert: trace targets size equals: 2
]

{ #category : #running }
SeqTraceTest >> testThroughput [
	"Given two blocks with latency 20 & 5 ms, the throughput of
	the system must be ~1000/(20+5) = 40 FPS (in case of naive execution)"
	self assert: trace throughput equals: 40. 
]
