Class {
	#name : #SeqEventStreamTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqEventStreamTest >> testAdvance [
	| s |
	s := SeqEventStream with: ('A' asSeqBlock latency: 1 ms; yourself).
	s updateTimePoint: 0 ms.
	s updateFrame: SeqFrame new.
	s advance.
	
	"Given the block execution FSM, once a stream is advanced, the next event time should change"
	self assert: s canWork.
	self assert: s nextTick equals: 1 ms.
	
	s updateTimePoint: 1 ms.
	s advance.
	self shouldnt: s canWork. "Still true as the execution is looped"
]

{ #category : #tests }
SeqEventStreamTest >> testCanWorkEmpty [
	| s1 |	
	"canStart is nil, block contents is nil: can't work"

	s1 := SeqEventStream new.
	self shouldnt: s1 canWork. 

	
	
]

{ #category : #tests }
SeqEventStreamTest >> testCanWorkEmptyButCanStart [
	| s1 |	

	"canStart is NOT nil, block contents is nil: depends on block"
	s1 := SeqEventStream new.
	s1 canStartTest: [ false ].
	self shouldnt: s1 canWork.
	
	s1 canStartTest: [ true ].
	self assert: s1 canWork 

	
	
]

{ #category : #tests }
SeqEventStreamTest >> testCanWorkWithBlock [
	| s |
	
	"canStart is nil, but block has contents - should work AFTER frame is specified"
	
	s := SeqEventStream with: (SeqBlock new latency: 1 ms; yourself).
	self shouldnt: s canWork.
	
	s updateFrame: SeqFrame new.
	self assert: s canWork. 
]

{ #category : #tests }
SeqEventStreamTest >> testCanWorkWithBlockCond [
	| s |
	s := SeqEventStream with: (SeqBlock new latency: 1 ms; yourself).
	s canStartTest: [ false ].
	self shouldnt: s canWork
]

{ #category : #tests }
SeqEventStreamTest >> testLoop [
	| s startCalls completeCalls |
	startCalls := 0.
	completeCalls := 0.

	s := SeqEventStream with: ('A' asSeqBlock latency: 1 ms; yourself).
	s onStart: [ startCalls := startCalls + 1 ].
	s onComplete: [ completeCalls := completeCalls + 1 ].

	1 to: 10 do: [ :i |
		s updateFrame: SeqFrame new.
		s updateTimePoint: i ms.
		s advance.
		s advance.
	
		self assert: startCalls equals: i.
		self assert: completeCalls equals: i].	

]

{ #category : #tests }
SeqEventStreamTest >> testNextTickOneBlock [
	| s |
	s := SeqEventStream with: ('A' asSeqBlock latency: 1 ms; yourself).
	s updateFrame: SeqFrame new.
	s updateTimePoint: 0 ms.
	self assert: s nextTick equals: 0 ms.
	
]

{ #category : #tests }
SeqEventStreamTest >> testOnComplete [
	| s completeCalled |
	completeCalled := false.

	s := SeqEventStream with: ('A' asSeqBlock latency: 1 ms; yourself).
	s updateFrame: SeqFrame new.
	s onComplete: [ completeCalled := true ].
	s updateTimePoint: 0 ms.
	s advance. "Enters block A execution"
	s updateTimePoint: 1 ms.
	s advance. "Completes block A execution, as well as the stream"
	
	self assert: completeCalled.
]

{ #category : #tests }
SeqEventStreamTest >> testOnStart [
	| s startCalled |
	startCalled := false.

	s := SeqEventStream with: ('A' asSeqBlock latency: 1 ms; yourself).
	s updateFrame: SeqFrame new.
	s onStart: [ startCalled := true ].
	s updateTimePoint: 0 ms.
	s advance. "Enters block A execution"
	
	self assert: startCalled.
]
