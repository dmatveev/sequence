Extension { #name : #String }

{ #category : #'*Sequence' }
String >> asSeqBlock [
	^SeqBlock new
		name: self;
		yourself
]
