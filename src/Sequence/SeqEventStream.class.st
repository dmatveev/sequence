Class {
	#name : #SeqEventStream,
	#superclass : #Object,
	#instVars : [
		'nextEventTime',
		'blockStream',
		'thisFrame',
		'thisToken',
		'thisState',
		'thisBlock',
		'thisTimePoint',
		'completeBlock',
		'startBlock',
		'seqBlocks',
		'canStartBlock',
		'startBlockCalled'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqEventStream class >> on: aCollection [ 
	^self new
		seqBlocks: aCollection;
		yourself
]

{ #category : #'instance creation' }
SeqEventStream class >> with: aSeqBlock [ 
	^self on: { aSeqBlock }
]

{ #category : #simulation }
SeqEventStream >> advance [
	thisState = #idle ifTrue: [ ^self handleAdvanceIdle ].
	thisState = #ready ifTrue: [ ^self handleAdvanceStart ].
	thisState = #exec ifTrue: [ ^self handleAdvanceExec ].
	
]

{ #category : #attributes }
SeqEventStream >> canStartTest: aBlockClosure [ 
	canStartBlock := aBlockClosure
]

{ #category : #attributes }
SeqEventStream >> canWork [
	"#canWork is defined by state. The precondition is only checked at #idle"
	thisState = #idle ifTrue: [ ^canStartBlock ifNil: [ false ] ifNotNil: canStartBlock ].
	^thisState = #ready or: (thisState = #exec)
]

{ #category : #private }
SeqEventStream >> enterNewBlock [
	thisBlock := blockStream peek.
	thisToken := thisBlock target tryLock: thisBlock at: thisTimePoint inContextOf: thisFrame.
	thisToken ifNil: [ self error: 'Should never happen, please check our resource allocation' ].
	nextEventTime := thisTimePoint + (thisBlock durationOn: thisFrame).
]

{ #category : #initialization }
SeqEventStream >> handleAdvanceExec [
	self leaveThisBlock.
	blockStream atEnd
		ifFalse: [self enterNewBlock]
		ifTrue: [ thisState := #idle.
					 completeBlock ifNotNil: completeBlock.
					 startBlockCalled := false.]
]

{ #category : #simulation }
SeqEventStream >> handleAdvanceIdle [
	"Can enter here IF and only IF we haven't been moved to the #ready state yet
	by the #updateFrameCall AND a #canWorkTest resulted true."
	self assert: startBlock isNotNil.
	startBlock value.
	
	"After triggering the startBlock (which MUST move us to #ready state),
	advance the execution to move to #exec (since the actual execution is what
	expected from advance)"
	self assert: thisState = #ready.
	startBlockCalled := true. "Mark as called to avoid extra side effects in the next
	state"
	self advance.
]

{ #category : #private }
SeqEventStream >> handleAdvanceStart [
	startBlockCalled ifFalse: [
		startBlock ifNotNil: startBlock.
		startBlockCalled := true].
	self enterNewBlock.
	thisState := #exec
]

{ #category : #initialization }
SeqEventStream >> initialize [
	super initialize.
	nextEventTime := 0 ms.
	thisState := #idle.
	startBlockCalled := false.
	
	"Define the FSM:
                     #updateFrame:     . #advance . . . .
            canStart?  :              :                 :
	      +------+   :  :   +-------+  :  +-----------+  :
	      | Ilde | -(?)---> | Ready | --> | Execution | ---.
	      +------+          +-------+     +-----------+    |
              ^                          |      ^       |
	           '--------------------------'      '-------'
	            #updateFrame:
	The next tick (see #nextTick) and the aciton under #advance: are defined given the state."

]

{ #category : #private }
SeqEventStream >> leaveThisBlock [
	thisBlock target release: thisToken.
	thisToken := nil.
	blockStream next.
	thisTimePoint := nextEventTime.

]

{ #category : #accessing }
SeqEventStream >> nextTick [
	"Bits of self-control: the yet-to-be happened event time should never get past
	the current time point."
	self assert: nextEventTime >= thisTimePoint.
	^nextEventTime
]

{ #category : #stream }
SeqEventStream >> onComplete: aCompleteBlock [
	completeBlock := aCompleteBlock 
]

{ #category : #stream }
SeqEventStream >> onStart: aStartBlock [
	startBlock := aStartBlock
]

{ #category : #attributes }
SeqEventStream >> seqBlocks: aCollection [ 
	"Note: this method remembers a collection of blocks but doesn't form an execution stream.
	The execution stream is formed when there's a frame passed"
	seqBlocks := aCollection
]

{ #category : #attributes }
SeqEventStream >> updateFrame: aSeqFrame [
	| blocksForFrame |
	
	"Only accept frame updates in #idle state. Prohibited in all others!"
	self assert: thisState = #idle.
	
	thisFrame := aSeqFrame.
	thisState := #ready.

	"Interpret the operation sequence with respect to the frame"
	blocksForFrame := OrderedCollection new.
	seqBlocks do: [ :each | each applyTo: aSeqFrame with: [ blocksForFrame add: each ] ].
	blockStream := blocksForFrame readStream
]

{ #category : #attributes }
SeqEventStream >> updateTimePoint: aTimePoint [
	thisTimePoint := aTimePoint.
	thisState = #idle ifTrue: [ nextEventTime := thisTimePoint. ]

]
