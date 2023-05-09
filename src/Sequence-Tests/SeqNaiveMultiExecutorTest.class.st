Class {
	#name : #SeqNaiveMultiExecutorTest,
	#superclass : #TestCase,
	#instVars : [
		'exec'
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
SeqNaiveMultiExecutorTest >> testFrameDrop [
	| src op seq trace cntrs |
	src := 'Src' asSeqBlock latency: 10 ms; live.
	op := 'Op' asSeqBlock latency: 20 ms.
	src >> op.
	seq := Sequence startingWith: src.

	exec add: seq value options: (SeqExecOptions new dropFrames).
	exec runFor: 101 ms.
	cntrs := exec counters: seq.
	trace := exec trace.
	
	"There must be frames dropped int the counters"
	self assert: (cntrs at: #completedFrames) equals: 5.
	self assert: (cntrs at: #droppedFrames)   equals: 4.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testJustLiveSource [
	"Stream executor should handle the case where there's just a live source and nothing else."
	
	| src seq trace |
	src := 'Src' asSeqBlock latency: 1 ms; live.
	seq := Sequence startingWith: src.
	exec add: seq.
	exec runFor: 10 ms.
	
	"There may be no counters for such sequence, it is FIXME for now.
	But other modelling properties must be in place."
	trace := exec trace.
	self assert: trace allLanes size equals: 1.
	self assert: trace allLanes first events size equals: 10.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testJustOperation [
	"Stream executor should handle the case where there's just an operation and nothing else."
	
	| src seq trace |
	src := 'Op' asSeqBlock latency: 1 ms.
	seq := Sequence startingWith: src.
	exec add: seq.
	exec runFor: 10 ms.
	
	"There may be no counters for such sequence, it is FIXME for now.
	But other modelling properties must be in place."
	trace := exec trace.
	self assert: trace allLanes size equals: 1.
	self assert: trace allLanes first events size equals: 10.
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

	| seq1 seq2 ctrs1 ctrs2 |
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
SeqNaiveMultiExecutorTest >> testStreamsCompetingShouldShareResource [
	| seq1 seq2 tgt liveLanes opLanes seq1Evs seq2Evs trace |

	seq1 := self makeSequence name: 'Seq1'.
	seq2 := self makeSequence name: 'Seq2'.
	
	"Make some competition now..."
	tgt := SeqTarget new.
	seq1 topoSorted last target: tgt.
	seq2 topoSorted last target: tgt.

	"Note: this test tests streams of the same priority!"
	exec add: seq1.
	exec add: seq2.
	exec scheduler: SeqRoundRobinScheduler new.
	exec runFor: 10 ms.
	
	"While the operation blocks compete, they have a lower invocation counts.
	Live blocks continue as normal!"
	trace := exec trace.
	liveLanes := trace allLanes select: [ :each | each allLive ].
	opLanes   := trace allLanes reject: [ :each | each allLive ].
	self assert: liveLanes size equals: 2.
	self assert: opLanes size equals: 1.

	self assert: liveLanes first  events size equals: 9. "One of the sources"
	self assert: liveLanes second events size equals: 9. "Another of the sources".
	
	seq1Evs := opLanes first events select: [ :each | each frame sequence == seq1 ].
	seq2Evs := opLanes first events select: [ :each | each frame sequence == seq2 ].
	self assert: seq1Evs size equals: 5.
	self assert: seq2Evs size equals: 4.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testStreamsCompetingWithPriority [
	| seq1 seq2 ctrs1 ctrs2 tgt trace liveLanes |

	seq1 := self makeSequence name: 'Seq 1'.
	seq2 := self makeSequence name: 'Seq 2'.
	
	"Make some competition now..."
	tgt := SeqTarget new.
	seq1 topoSorted last target: tgt.
	seq2 topoSorted last target: tgt.

	exec add: seq1 priority: 10.
	exec add: seq2 priority: 0.
	exec scheduler: SeqPriorityRRScheduler new.
	exec runFor: 10 ms.

	ctrs1 := exec counters: seq1.
	ctrs2 := exec counters: seq2.
	
	self assert: (ctrs1 at: #completedFrames) equals: 9. "Prioritized stream should take it all"
	self assert: (ctrs2 at: #completedFrames) equals: 0. "Deprioritized -- sorry mate."
	
	"However, the _live_ source of the deprioritized one should still run!"
	trace := exec trace.
	liveLanes := trace allLanes select: [ :each | each allLive ].
	self assert: liveLanes size equals: 2.

	self assert: liveLanes first  events size equals: 9. "One of the sources"
	self assert: liveLanes second events size equals: 9. "One of the sources"
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testStreamsNonCompetingShouldRun [
	| seq1 seq2 ctrs1 ctrs2 |

	seq1 := self makeSequence name: 'Seq 1'.
	seq2 := self makeSequence name: 'Seq 2'.

	"Note: this isn't about priorities, too"
	exec add: seq1.
	exec add: seq2.
	exec runFor: 10 ms.

	ctrs1 := exec counters: seq1.
	ctrs2 := exec counters: seq2.
	
	self assert: (ctrs1 at: #completedFrames) equals: 8.
	self assert: (ctrs2 at: #completedFrames) equals: 8.
]

{ #category : #tests }
SeqNaiveMultiExecutorTest >> testStreamsNonCompetingWithPriorityShouldRun [
	| seq1 seq2 ctrs1 ctrs2 |

	seq1 := self makeSequence name: 'Seq 1'.
	seq2 := self makeSequence name: 'Seq 2'.

	exec add: seq1 priority: 10.
	exec add: seq2 priority: 5.
	exec scheduler: SeqPriorityRRScheduler new.
	exec runFor: 10 ms.

	ctrs1 := exec counters: seq1.
	ctrs2 := exec counters: seq2.

	"As the blocks aren't competing for the same resource, even served
	with different priorities, they need to have the same time allocation"	
	self assert: (ctrs1 at: #completedFrames) equals: 8.
	self assert: (ctrs2 at: #completedFrames) equals: 8.
]
