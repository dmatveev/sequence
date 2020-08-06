Class {
	#name : #SeqBlockTest,
	#superclass : #TestCase,
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqBlockTest >> setUp [
	super setUp.
	a := 'A' asSeqBlock.
	b := 'B' asSeqBlock.
	c := 'C' asSeqBlock.
]

{ #category : #running }
SeqBlockTest >> testChain [
	a >> b.
	self assert: (a produces: b).
	self assert: (b consumes: a).
	self deny: (a consumes: b).
	self deny: (b produces: a).
]

{ #category : #running }
SeqBlockTest >> testChainBranch [
	a >> b >> c.
	a >> c.
	self assert: (a produces: b).
	self assert: (b produces: c).
	self assert: (b consumes: a).
	self assert: (c consumes: b).
	self assert: (c consumes: a).
	self assert: (a produces: c).
]

{ #category : #running }
SeqBlockTest >> testChainLong [
	a >> b >> c.
	self assert: (a produces: b).
	self assert: (b produces: c).
	self assert: (b consumes: a).
	self assert: (c consumes: b).
	self deny: (c consumes: a).
	self deny: (a produces: c).
]

{ #category : #running }
SeqBlockTest >> testChainSelf [
	self should: [a >> a] raise: SeqCycleException.
]
