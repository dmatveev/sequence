Extension { #name : #SequenceableCollection }

{ #category : #'*Sequence' }
SequenceableCollection >> asSeqLaneMocks [
	^self collect: [ :each | SeqLaneMock new locked: each = 1 ].
]
