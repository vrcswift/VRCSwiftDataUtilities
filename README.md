# VRCSwiftDataUtilities

This library is a data utilities for VRC Swift.

## APIs

### (Class)  VRCDataFetcher

Data fetcher.

#### (Constructor) VRCDataFetcher.init(data: Data)

Initialize with copying bytes.

<u>Parameter</u>

- data (*Data*): The data.

#### (Method) VRCDataFetcher.fetch() -> UInt8

Fetch one byte.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): Raised if there is no bytes.

<u>Returns</u>

- The byte.

#### (Method) VRCDataFetcher.fetchAll() -> Data

Fetch all bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): Raised if stream is ended.

<u>Returns</u>

- The bytes.

#### (Method) VRCDataFetcher.fetchBytes(count: Data.Index) -> Data

Fetch bytes with specific count.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): The fetcher is already ended.
- VRCDataFetcherError (*outOfRange*): The count is out of range.
- VRCDataFetcherError (*parameterError*): count < 0.

<u>Parameter</u>

- count (*Data.Index*): The count.

<u>Returns</u>

- The bytes.

#### (Method) VRCDataFetcher.skip(steps: Data.Index)

Skip specific bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): The fetcher is already ended.
- VRCDataFetcherError (*outOfRange*): The count is out of range.
- VRCDataFetcherError (*parameterError*): steps < 0.

<u>Parameter</u>

- steps (*Data.Index*): The count of bytes to be skipped.

#### (Method) VRCDataFetcher.getRemainCount() -> Data.Index

Get count of remaining bytes.

<u>Returns</u>

- The count.

#### (Method) VRCDataFetcher.isEnd() -> Bool

Check whether fetcher is end.

<u>Returns</u>

- True if so.

#### (Method) VRCDataFetcher.reset()

Reset position.

#### (Method) VRCDataFetcher.reinit(data: Data)

Reinit fetcher with copying data.

<u>Parameter</u>

- data (*Data*): The data.

### (Class)  VRCBlockDataFetcher

Block data fetcher.

#### (Constructor) VRCBlockDataFetcher.init(blocks: [Data])

Constructor of block data fetcher.

<u>Parameter</u>

- blocks (*[Data]*): The blocks.

#### (Method) VRCBlockDataFetcher.fetch() -> UInt8

Fetch one byte.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): Raised if there is no bytes.

<u>Returns</u>

- The byte.

#### (Method) VRCBlockDataFetcher.fetchAll() -> Data

Fetch all bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): Raised if stream is ended.

<u>Returns</u>

- The bytes.

#### (Method) VRCBlockDataFetcher.fetchAllAsBlocks() -> [Data]

Fetch all bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): Raised if stream is ended.

<u>Returns</u>

- The blocks.

#### (Method) VRCBlockDataFetcher.fetchBytes(count: Data.Index) -> Data

Fetch specific bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): The fetcher is already ended.
- VRCDataFetcherError (*outOfRange*): The bytes count is out of range.
- VRCDataFetcherError (*parameterError*): count < 0.

<u>Parameter</u>

- count (*Data.Index*): The bytes count.

<u>Returns</u>

- The bytes.

#### (Method) VRCBlockDataFetcher.fetchBytesAsBlocks(count: Data.Index) -> [Data]

Fetch specific bytes as blocks.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): The fetcher is already ended.
- VRCDataFetcherError (*outOfRange*): The bytes count is larger than remain count.
- VRCDataFetcherError (*parameterError*): count < 0.

<u>Parameter</u>

- count (*Data.Index*): The bytes count.

<u>Returns</u>

- The buffer blocks.

#### (Method) VRCBlockDataFetcher.skip(steps: Data.Index)

Skip specific bytes.

<u>Throws</u>

- VRCDataFetcherError (*endOfStream*): The fetcher is already ended.
- VRCDataFetcherError (*outOfRange*): The count of bytes to be skipped is larger than remain count.
- VRCDataFetcherError (*parameterError*): steps < 0.

<u>Parameter</u>

- steps (*Data.Index*): The count of bytes to be skipped.

#### (Method) VRCBlockDataFetcher.getRemainCount() -> Data.Index

Get count of remaining bytes.

<u>Returns</u>

- The count.

#### (Method) VRCBlockDataFetcher.isEnd() -> Bool

Get whether cursor reached the end.

<u>Returns</u>

- True if ended.

#### (Method) VRCBlockDataFetcher.reset()

Reset cursor.

#### (Method) VRCBlockDataFetcher.reinit(newBlocks: [Data])

Reinitialize object.

<u>Parameter</u>

- newBlocks (*[Data]*): New blocks.

### (Class) VRCDataMerger

Data merger.

#### (Method) VRCDataMerger.push(data: Data)

Push a data object.

<u>Parameter</u>

- data (*Data*): The data.

#### (Method) VRCDataMerger.merge() -> Data

Merget pushed data.

<u>Returns</u>

The data.

#### (Method) VRCDataMerger.reset()

clear pushed data.

### (Function) MergeBufferBlocks(blocks: [Data]) -> Data

Merge data blocks to one data object.

<u>Parameter</u>

- blocks (*[Data]*): The blocks to be concatencated.

<u>Returns</u>

The concatencated buffer.
