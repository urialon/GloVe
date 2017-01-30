#!/bin/bash
if [ $# -lt 2 ]
    then
        echo "Usage: uridemo.sh <length> <width>"
        exit 1
fi
length=$1
width=$2
set -e

# Makes programs, downloads sample data, trains a GloVe model, and then evaluates it.
# One optional argument can specify the language used for eval script: matlab, octave or [default] python

make

CORPUS=../UnuglifyJS/glove_models/jsnice_training_clean${length}x${width}.txt
MODEL_NAME=$(echo $CORPUS | tr '/' "\n" | tr '.' "\n" | tail -2 | head -1)
VOCAB_FILE=models/$MODEL_NAME/vocab.txt
COOCCURRENCE_FILE=models/$MODEL_NAME/cooccurrence.bin
COOCCURRENCE_SHUF_FILE=models/$MODEL_NAME/cooccurrence.shuf.bin
BUILDDIR=build
SAVE_FILE=models/$MODEL_NAME/vectors
VERBOSE=2
MEMORY=4.0
VOCAB_MIN_COUNT=100
VECTOR_SIZE=150
MAX_ITER=30
WINDOW_SIZE=1
BINARY=2
NUM_THREADS=64
X_MAX=10
MODEL=1
ETA=0.05

if [ ! -d "models" ]; then
  mkdir models
fi
cd models
if [ ! -d "$MODEL_NAME" ]; then
  mkdir $MODEL_NAME
fi
cd ..

echo "$ $BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE"
$BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE
echo "$ $BUILDDIR/cooccur -symmetric 0 -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE"
$BUILDDIR/cooccur -symmetric 0 -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE
echo "$ $BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE"
$BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE
echo "$ $BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE -model $MODEL"
$BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE -model $MODEL -eta $ETA -filter_paths 1
