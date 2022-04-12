Class {
	#name : #SeqLiveSourceTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #initialization }
SeqLiveSourceTest >> setUp [
	super setUp
]

{ #category : #initialization }
SeqLiveSourceTest >> testCreation [
	| src |
	src := 'Src' asSeqBlock.
	self assert: src isLive equals: false.
	src live.
	self assert: src isLive.
]

{ #category : #initialization }
SeqLiveSourceTest >> testSequenceCreation [
	| src a |
	src := 'Src' asSeqBlock live.
	a := 'A' asSeqBlock.
	src >> a.
	Sequence startingWith: src. "Throws no exceptions"
	
]

{ #category : #initialization }
SeqLiveSourceTest >> testSequenceThrowIfMany [
	| src1 src2 a |
	src1 := 'Src1' asSeqBlock live.
	src2 := 'Src2' asSeqBlock live.
	a := 'A' asSeqBlock.
	src1 >> src2 >> a.
	self should: [Sequence startingWith: src1] raise: SeqMultipleLiveSourcesFound
]

{ #category : #initialization }
SeqLiveSourceTest >> testShouldBeFirstInSequence [
	| a b |
	a := 'A' asSeqBlock.
	b := 'B' asSeqBlock.
	a >> b.
	b live.
	self should: [ Sequence startingWith: a ] raise: SeqLiveSourceMustBeFirst .
]
