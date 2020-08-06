Class {
	#name : #SeqTargetTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqTargetTest >> testLanes [
	| tgt |
	tgt := SeqTarget new.
	self assert: tgt lanes equals: 1.
	
	tgt lanes: 4.
	self assert: tgt lanes equals: 4.
]

{ #category : #tests }
SeqTargetTest >> testLock1 [
	| tgt blk start |
	start := 0 seconds.
	blk := 'Process' asSeqBlock latency: 20 ms. "1-lane seq block"
	tgt := SeqTarget new. "1-lane target"
	self assert: (tgt tryLock: blk at: start). "Should be ok"
	self deny: (tgt tryLock: blk at: (start + 10 ms)). "Resource is busy"
	tgt release: blk.
	"In the end, there must be a single event registered for this target"
	self assert: tgt events size equals: 1.
]
