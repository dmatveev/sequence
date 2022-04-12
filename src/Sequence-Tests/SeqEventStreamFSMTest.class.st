Class {
	#name : #SeqEventStreamFSMTest,
	#superclass : #TestCase,
	#instVars : [
		'started',
		'finished',
		'evStream'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqEventStreamFSMTest >> setUp [
	| arr |

	super setUp.

	started := 0.
	finished := 0.
	arr := Array
		with: ('A' asSeqBlock latency: 10 ms; yourself)
		with: ('B' asSeqBlock latency: 5 ms; yourself).
	evStream := SeqEventStream on: arr.
	evStream onStart: [ started := started + 1 ].
	evStream onComplete: [ finished := finished + 1 ].
]

{ #category : #accessing }
SeqEventStreamFSMTest >> stateOf: anEventStream [
	^anEventStream instVarNamed: 'thisState'
]

{ #category : #tests }
SeqEventStreamFSMTest >> testFSM [
	".| A | B |
	 12   3   4"
	
	"Check point (1): Everything is ready for execution, but is not actually executed"
	evStream updateFrame: SeqFrame new.
	evStream updateTimePoint: 0 ms.
	self assert: evStream canWork.
	self assert: evStream nextTick equals: 0 ms.
	self assert: started equals: 0.
	self assert: finished equals: 0.
	
	"Switch to point (2): A locks its target. Next event should be at 10ms"
	evStream advance.
	self assert: evStream nextTick equals: 10 ms.
	self assert: started equals: 1.
	
	"Switch to point (3): A completes"
	evStream advance.
		
	" B starts. Next event should be at 15ms (10+5)"
	evStream advance.
	self assert: evStream nextTick equals: 15 ms.
	
	"Complete B's execution (4). Assume A is started. next tick from now is 25ms (15+10)"
	evStream advance.
	self assert: finished equals: 1.

]
