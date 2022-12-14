Class {
	#name : #SeqNaiveMultiExecutorTest,
	#superclass : #TestCase,
	#instVars : [
		'exec',
		'ctrs2'
	],
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqNaiveMultiExecutorTest >> makeSequence [
	| src op | 
	src := 'Src' asSeqBlock latency: 1 ms; live.
	op  := 'Op' asSeqBlock latency: 1 ms.
	src >> op.
	^Sequence startingWith: src
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> setUp [
	super setUp.
	exec := SeqNaiveMultiExecutor new.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testAddWith [
	| seq ctrs |
	seq := self makeSequence.
	exec add: seq with: [ ].
	
   "Check counters for the newly added sequence. Before execution, it must be all 0s"
	ctrs := exec counters: seq.
	self assert: (ctrs at: #completedFrames) equals: 0.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testRunFor [
	"Run a single simple sequence and check the counters.
	FIXME counters could be checked better!"

	| seq ctrs |
	seq := self makeSequence.
	exec add: seq.
	exec runFor: 10 ms.
	
	ctrs := exec counters: seq.
	
	"A 2 ms pipeline should execute.. 4 times in 10ms window:
   0 2 4 6 8 10
    ++++++++++
     xxxxxxxxx
	"
	self assert: (ctrs at: #completedFrames) equals: 9.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testRunFor2 [
	"Run two simple sequences and check the counters"

	| seq1 seq2 ctrs1 |
	seq1 := self makeSequence.
	seq2 := self makeSequence.
	exec add: seq1.
	exec add: seq2.
	exec runFor: 10 ms.
	
	ctrs1 := exec counters: seq1.
	ctrs2 := exec counters: seq2.
	
	"These two pipelines don't compete for device, their counters should match"
	self assert: (ctrs1 at: #completedFrames) equals: 8. "Why not 9 for both? See #1 on Github"
	self assert: (ctrs2 at: #completedFrames) equals: 8.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testScheduler [
	"So far this is a pretty dumb check"
]
