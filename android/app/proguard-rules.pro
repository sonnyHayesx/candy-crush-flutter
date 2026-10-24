# Room 2.2.5 (transitive through WorkManager) instantiates this generated
# database reflectively. AGP 9's strict R8 rules keep the class but no longer
# implicitly keep its no-argument constructor. Without this rule, the release
# crashes in InitializationProvider before Flutter starts.
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
