Class {
	#name : #SeqTargetTest,
	#superclass : #TestCase,
	#instVars : [
		'start',
		'blk',
		'tgt'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqTargetTest >> setUp [
	super setUp.
	start := 0 seconds.
	blk := 'Process' asSeqBlock latency: 20 ms. "1-lane seq block"
	tgt := SeqTarget new. "1-lane target"
]

{ #category : #tests }
SeqTargetTest >> testBusy [
	| frame |
	frame := 0.

   "Should be ok"
	self assert: (tgt tryLock: blk at: start inContextOf: frame) isNotNil.

	"Resource is busy"
	self assert: (tgt tryLock: blk at: (start + 10 ms) inContextOf: frame) isNil. 

	"Resource is busy, even after block's duration. Explicit release is required."
	self assert: (tgt tryLock: blk at: (start + 10 seconds) inContextOf: frame) isNil
]

{ #category : #tests }
SeqTargetTest >> testLanes [
	| target |
	target := SeqTarget new.
	self assert: target lanes equals: 1.
	
	target lanes: 4.
	self assert: target lanes equals: 4.
]

{ #category : #tests }
SeqTargetTest >> testLoadedContinuous [
	| target block tokens frame |
	frame := 0.
	target := SeqTarget new lanes: 8.
	block := SeqBlock new latency: 20 ms; lanes: 2; allocPolicy: #continuous.

	"Load all lanes"
	tokens := (0 to: 3) collect: [ :i | target tryLock: block at: i ms inContextOf: frame ].
	self assert: (tokens allSatisfy: #isNotNil).
	
	"No way to lock anything"
	self assert: (target tryLock: block at: 5 ms inContextOf: frame) isNil.
	
	"Release a lane"
	target release: tokens second.
	
	"Now this should succeed again"
	self assert: (target tryLock: block at: 20 ms inContextOf: frame) isNotNil
]

{ #category : #tests }
SeqTargetTest >> testLoadedSparse [
	| target block1 block2 tokens frame |
	frame := 0.
	target := SeqTarget new lanes: 8.
	block1 := SeqBlock new latency: 20 ms; lanes: 2; allocPolicy: #continuous.
	block2 := SeqBlock new latency: 25 ms; lanes: 4; allocPolicy: #sparse.

	"Load all lanes"
	tokens := (0 to: 3) collect: [ :i | target tryLock: block1 at: i ms inContextOf: frame ].
	self assert: (tokens allSatisfy: #isNotNil).
	
	"No way to lock anything: note: now for block2"
	self assert: (target tryLock: block2 at: 5 ms inContextOf: frame) isNil.
	
	"Release a lane"
	target release: tokens first.

	"Still no way to run block2"
	self assert: (target tryLock: block2 at: 5 ms inContextOf: frame) isNil.

	"Release one more lane"
	target release: tokens last.
	
	"Now this should succeed again"
	self assert: (target tryLock: block2 at: 5 ms inContextOf: frame) isNotNil
]

{ #category : #tests }
SeqTargetTest >> testRelease [
	| token frame |
	frame := 0.
	token := tgt tryLock: blk at: start inContextOf: frame.
	self assert: token isNotNil. "Should be ok"
	self assert: (tgt tryLock: blk at: (start + 10 ms) inContextOf: frame) isNil. "Resource is busy"
	tgt release: token.
	"In the end, there must be a single event registered for this target"
	self assert: tgt events size equals: 1.
]

{ #category : #tests }
SeqTargetTest >> testTryLockAt [
	self assert: (tgt tryLock: blk at: start inContextOf: 0) isNotNil. "Should be ok"
]

{ #category : #tests }
SeqTargetTest >> testTryLockAt2 [
	| frame |
	frame := 0.
	self assert: (tgt tryLock: blk at: start inContextOf: frame) isNotNil. "Should be ok"
	self assert: (tgt tryLock: blk at: (start + 10 ms) inContextOf: frame) isNil. "Resource is busy"

]
