// The main entry point.
def main(): Unit \ IO =
    println("Hello World!")

enum Blob({key = String})

enum Bucket({name = String})

enum Storage({basePath = String})

trait Object[a] {
    pub def path(storage: Storage, object: a): String
}

instance Object[Bucket] {
    pub def path(storage: Storage, bucket: Bucket): String = 
        let Storage.Storage({basePath}) = storage;
        let Bucket.Bucket({name}) = bucket;
        basePath + name
}

def create(bucket: Bucket): Result[IoError, Unit] \ FileWriteWithResult =
    let Bucket.Bucket({name}) = bucket;
    let path = Object.path(?storage, bucket);
    FileWriteWithResult.mkDir(path)
