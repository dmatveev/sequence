Class {
	#name : #SeqTraceWithLiveSourceTest,
	#superclass : #TestCase,
	#instVars : [
		'trace',
		'cam',
		'proc'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqTraceWithLiveSourceTest >> runTraceForCamera: cameraLatency andProcessing: processingLatency for: aDuration [
	cam latency: cameraLatency.
	proc latency: processingLatency.
	trace := (Sequence startingWith: cam) runFor: aDuration using: SeqNaiveExecutor 
]

{ #category : #running }
SeqTraceWithLiveSourceTest >> setUp [
	super setUp.
	"20ms is unusual for Camera, but convenient for testing"
	cam := 'Camera' asSeqBlock.
	cam live.
	proc := 'Process' asSeqBlock.
	cam >> proc.
]

{ #category : #running }
SeqTraceWithLiveSourceTest >> testInvocationsPipelineDoesntFit [
	| ev1 ev2|
	self runTraceForCamera: 20 ms andProcessing: 40 ms for: 100 ms.
	ev1 := cam target events.
	ev2 := proc target events.
	
	"In a 100 ms run, a 20ms LIVE camera should trigger 5 times. Still"
	self assert: ev1 size equals: 5.
	
	"Proc is able to process only two events"
	self assert: ev2 size equals: 2.
]

{ #category : #running }
SeqTraceWithLiveSourceTest >> testInvocationsPipelineFits [
	| ev1 ev2|
	self runTraceForCamera: 20 ms andProcessing: 5 ms for: 100 ms.
	ev1 := cam target events.
	ev2 := proc target events.
	
	"In a 100 ms run, a 20ms LIVE camera should trigger 5 times"
	self assert: ev1 size equals: 5.
	
	"But proc can make it only for 4"
	self assert: ev2 size equals: 4.
]
