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
SeqTraceTest >> testFrameDataUpdate [
	| a frames |
	frames := OrderedCollection new.

	a := 'A' asSeqBlock latency: 1 ms.
	a job: [ :f | f data add: f id ].
	
	(Sequence startingWith: a)
		runFor: 5 ms
		using: SeqNaiveScheduler
		on: [ frames ].
	self assert: frames equals: (0 to: 4) asOrderedCollection
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
SeqTraceTest >> testJob [
	| a frames |
	frames := OrderedCollection new.

	a := 'A' asSeqBlock latency: 1 ms.
	a job: [ :f | frames add: f id ].
	
	(Sequence startingWith: a)
		runFor: 5 ms
		using: SeqNaiveScheduler.
	self assert: frames equals: (0 to: 4) asOrderedCollection
]

{ #category : #running }
SeqTraceTest >> testLatency [
	| a t |
	a := 'A' asSeqBlock latency: 1 ms.
	t := (Sequence startingWith: a) runFor: 5 ms using: SeqNaiveScheduler.
	self assert: (t allEvents size) equals: 5.
]

{ #category : #running }
SeqTraceTest >> testLatencyBlock [
	| a t |
	a := 'A' asSeqBlock latency: [ :f | 1 ms ].
	t := (Sequence startingWith: a) runFor: 5 ms using: SeqNaiveScheduler.
	self assert: (t allEvents size) equals: 5.
]

{ #category : #running }
SeqTraceTest >> testLatencyBlock2 [
	| a t |
	a := 'A' asSeqBlock latency: [ :f | (1 + f id) ms ].
	t := (Sequence startingWith: a) runFor: 6 ms using: SeqNaiveScheduler.
	self assert: (t allEvents size) equals: 3.
]

{ #category : #running }
SeqTraceTest >> testNumFrames [
	"Magic number 5*40 is 5 seconds with 40 FPS"
	self assert: trace numFrames equals: (5*40)
]

{ #category : #running }
SeqTraceTest >> testTasks [
	| a b ae be |

	a := 'A' asSeqBlock latency: 1 ms.
	b := 'B' asSeqBlock latency: 1 ms; tasks: [ :frame | 2 ].
	a >> b.

	(Sequence startingWith: a)
		runFor: 30 ms
		using: SeqNaiveScheduler.

	ae := a target execLanes first events.
	be := b target execLanes first events.

	"B must work 2x due to its #tasks config dependent on Stream contents.
	Because of this, A with a naive scheduler A should have just 10 invokations, not 15"
	self assert: ae size equals: 10.
	self assert: be size equals: 20. 
]

{ #category : #running }
SeqTraceTest >> testTasksStream [
	| a b cnt t |

	"Describe Sequence blocks"
	a := 'A' asSeqBlock latency: 1 ms.
	b := 'B' asSeqBlock latency: 2 ms; tasks: [ :f | f data ].
	cnt := 0.

	"Define the sequence"	
	a >> b.

	"Run the simulation"
	t := (Sequence startingWith: a)
		runFor: 33 ms
		using: SeqNaiveScheduler
		on: [ cnt := (cnt + 1) % 4. ].
		
	self assert: t numFrames equals: 8. "Not 11, due to variadic number of B tasks"
]

{ #category : #running }
SeqTraceTest >> testThroughput [
	"Given two blocks with latency 20 & 5 ms, the throughput of
	the system must be ~1000/(20+5) = 40 FPS (in case of naive execution)"
	self assert: trace throughput equals: 40. 
]

{ #category : #running }
SeqTraceTest >> testThroughputBug [
	"There was a bug with throughput calculated incorrectly if all blocks are assigned
	to the same target (wrong event has been selected as 'last' per lane"
	| t1 t2 | 
	t1 := [ | a b c |
		a := 'A' asSeqBlock latency: 5 ms.
		b := 'B' asSeqBlock latency: 10 ms.
		c := 'C' asSeqBlock latency: 15 ms.
		a >> b >> c.
		(Sequence startingWith: a) runFor: 1 second using: SeqNaiveScheduler].
	t2 := [ | t a b c |
		t := SeqTarget new.
		a := 'A' asSeqBlock latency: 5 ms; target: t.
		b := 'B' asSeqBlock latency: 10 ms; target: t.
		c := 'C' asSeqBlock latency: 15 ms; target: t.
		a >> b >> c.
		(Sequence startingWith: a) runFor: 1 second using: SeqNaiveScheduler].
	self assert: t1 value throughput closeTo: t2 value throughput
]
