Class {
	#name : #SeqFrameSourceTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqFrameSourceTest >> testBlockStream [
	| s arr |
	s := SeqFrameSource on: (SeqDataStream block: [ 42 ]).
 	arr := { 
		s next.
		s next.
		s next.
	}.
	0 to: 2 do: [ :i |
		self assert: (arr at: i+1) id equals: i.
		self assert: (arr at: i+1) data equals: 42].
]
